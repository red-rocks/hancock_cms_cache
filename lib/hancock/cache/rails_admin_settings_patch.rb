module Hancock::Cache
  module RailsAdminSettingsPatch
    extend ActiveSupport::Concern

    included do
      include Hancock::Cache::Cacheable

      rails_admin do
        navigation_label I18n.t('admin.settings.label')

        list do
          field :label do
            visible false
            searchable true
          end
          if Object.const_defined?('RailsAdminToggleable')
            field :enabled, :toggle
          else
            field :enabled
          end
          field :ns do
            searchable true
          end
          field :key do
            searchable true
          end
          field :name
          field :kind do
            searchable true
          end
          field :raw do
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
            searchable true
          end
          if ::Settings.table_exists?
            nss = ::RailsAdminSettings::Setting.pluck(:ns).uniq.map { |c| "ns_#{c.gsub('-', '_')}".to_sym }
            scopes([nil] + nss)
          end
        end

        edit do
          field :enabled, :toggle do
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
            visible do
              render_object = (bindings[:controller] || bindings[:view])
              render_object and (render_object.current_user.admin?)
            end
          end
          field :ns  do
            read_only true
            help false
            visible do
              render_object = (bindings[:controller] || bindings[:view])
              render_object and (render_object.current_user.admin?)
            end
          end
          field :key  do
            read_only true
            help false
            visible do
              render_object = (bindings[:controller] || bindings[:view])
              render_object and (render_object.current_user.admin?)
            end
          end
          field :label do
            read_only true
            help false
          end
          field :kind do
            read_only true
            help false
          end
          field :raw do
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

          group(:cache, &Hancock::Cache::Admin.caching_block do |_group|
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
