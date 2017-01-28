module Hancock::Cache
  module RailsAdminSettingsPatch
    extend ActiveSupport::Concern

    included do
      include ::Hancock::Cache::Cacheable

      rails_admin do
        navigation_label I18n.t('admin.settings.label')

        list do
          field :label do
            visible false
            searchable true
            weight 1
          end
          if Object.const_defined?('RailsAdminToggleable')
            field :enabled, :toggle do
              weight 2
            end
          else
            field :enabled do
              weight 2
            end
          end
          field :ns do
            searchable true
            weight 3
          end
          field :key do
            searchable true
            weight 4
          end
          field :name do
            weight 5
          end
          field :kind do
            searchable true
            weight 6
          end
          field :raw do
            weight 7
            searchable true
            pretty_value do
              if bindings[:object].file_kind?
                "<a href='#{CGI::escapeHTML(bindings[:object].file.url)}'>#{CGI::escapeHTML(bindings[:object].to_path)}</a>".html_safe.freeze
              elsif bindings[:object].image_kind?
                "<a href='#{CGI::escapeHTML(bindings[:object].file.url)}'><img src='#{CGI::escapeHTML(bindings[:object].file.url)}' /></a>".html_safe.freeze
              else
                value
              end
            end
          end
          field :cache_keys_str, :text do
            weight 6
            searchable true
          end
          if ::Settings.table_exists?
            nss = ::RailsAdminSettings::Setting.pluck(:ns).uniq.map { |c| "ns_#{c.gsub('-', '_')}".to_sym }
            scopes([nil] + nss)
          end
        end

        edit do
          field :enabled, :toggle do
            weight 1
            visible do
              if bindings[:object].for_admin?
                render_object = (bindings[:controller] || bindings[:view])
                render_object and (render_object.current_user.admin?)
              else
                true
              end
            end
          end
          field :for_admin, :toggle do
            weight 2
            visible do
              render_object = (bindings[:controller] || bindings[:view])
              render_object and (render_object.current_user.admin?)
            end
          end
          field :ns  do
            weight 3
            read_only true
            help false
            visible do
              render_object = (bindings[:controller] || bindings[:view])
              render_object and (render_object.current_user.admin?)
            end
          end
          field :key  do
            weight 4
            read_only true
            help false
            visible do
              render_object = (bindings[:controller] || bindings[:view])
              render_object and (render_object.current_user.admin?)
            end
          end
          field :label do
            weight 5
            read_only true
            help false
          end
          field :kind do
            weight 6
            read_only true
            help false
          end
          field :raw do
            weight 7
            partial "setting_value".freeze
            visible do
              !bindings[:object].upload_kind?
            end
            read_only do
              if bindings[:object].for_admin?
                render_object = (bindings[:controller] || bindings[:view])
                !(render_object and (render_object.current_user.admin?))
              else
                false
              end
            end
          end
          if Settings.file_uploads_supported
            field :file, Settings.file_uploads_engine do
              weight 8
              visible do
                bindings[:object].upload_kind?
              end
              read_only do
                if bindings[:object].for_admin?
                  render_object = (bindings[:controller] || bindings[:view])
                  !(render_object and (render_object.current_user.admin?))
                else
                  false
                end
              end
            end
          end

          group(:cache, &::Hancock::Cache::Admin.caching_block do |_group|
            _group.weight 9
            _group.visible do
              render_object = (bindings[:controller] || bindings[:view])
              render_object and render_object.current_user.admin?
            end
          end)

        end
      end

    end

  end
end





module RailsAdminSettings
  class Namespaced

    # returns setting object
    def get(key, options = {})
      key = key.to_s

      _detect_cache = !(::Hancock::Cache::Fragment.rails_admin_settings_ns == name and key == "detecting")
      if ::Hancock::Cache.config.model_settings_support
        _detect_cache &&= (::Hancock::Cache.config.runtime_cache_detector or ::Hancock::Cache::Fragment.settings.detecting)
      else
        _detect_cache &&= (::Hancock::Cache.config.runtime_cache_detector or Settings.hancock_cache_detecting)
      end

      load!

      mutex.synchronize do
        @locked = true

        if _detect_cache
          options[:cache_keys] ||= options.delete :cache_key
          _cache_keys = options[:cache_keys]
          if _cache_keys.nil?
            # if _cache
            #   options[:cache_keys_str] = name.underscore
            # end
          else
            if _cache_keys.is_a?(::Array)
              options[:cache_keys_str] = _cache_keys.map { |k| k.to_s }.join(" ")
            else
              options[:cache_keys_str] = _cache_keys.to_s
            end
          end
          _cache_keys = (options[:cache_keys_str] ? options[:cache_keys_str].split(" ") : [])
        end

        v = @settings[key]
        if v.nil?
          unless @fallback.nil? || @fallback == @name
            v = ::Settings.ns(@fallback).getnc(key)
          end
          if v.nil?
            v = set(key, options[:default], options)
          end
        end

        if _detect_cache and _cache_keys and !(_cache_keys - v.cache_keys).blank?
          options[:cache_keys_str] = (_cache_keys + v.cache_keys).uniq.join(" ")
          v = set(key, options[:default], options)
        end

        @locked = false
        v
      end
    end

  end
end
