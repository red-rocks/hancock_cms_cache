module Hancock::Cache
  module RailsAdminSettingsPatch
    extend ActiveSupport::Concern

    included do
      include ::Hancock::Cache::Cacheable

      def full_cached?
        self.cache_keys.count > 0 and self.cache_keys.count == self.cache_fragments.enabled.count
      end

      def reset_loadable
        self.loadable = !self.full_cached?
      end
      def reset_loadable!
        self.reset_loadable
        self.save
      end
      def self.reset_loadable!
        self.all.map(&:reset_loadable!)
      end

      rails_admin do
        navigation_label I18n.t('admin.settings.label')

        list do
          field :label do
            visible false
            searchable true
            weight 1
          end
          field :enabled, :toggle do
            weight 2
          end
          field :loadable, :toggle do
            weight 3
          end
          field :ns do
            searchable true
            weight 4
          end
          field :key do
            searchable true
            weight 5
          end
          field :name do
            weight 6
          end
          field :kind do
            searchable true
            weight 7
          end
          field :raw_data do
            weight 8
            pretty_value do
              if bindings[:object].file_kind?
                "<a href='#{CGI::escapeHTML(bindings[:object].file.url)}'>#{CGI::escapeHTML(bindings[:object].to_path)}</a>".html_safe.freeze
              elsif bindings[:object].image_kind?
                "<a href='#{CGI::escapeHTML(bindings[:object].file.url)}'><img src='#{CGI::escapeHTML(bindings[:object].file.url)}' /></a>".html_safe.freeze
              elsif bindings[:object].array_kind?
                (bindings[:object].raw_array || []).join("<br>").html_safe
              elsif bindings[:object].hash_kind?
                "<pre>#{JSON.pretty_generate(bindings[:object].raw_hash || {})}</pre>".html_safe
              else
                value
              end
            end
          end
          # field :raw do
          #   weight 8
          #   searchable true
          #   pretty_value do
          #     if bindings[:object].file_kind?
          #       "<a href='#{CGI::escapeHTML(bindings[:object].file.url)}'>#{CGI::escapeHTML(bindings[:object].to_path)}</a>".html_safe.freeze
          #     elsif bindings[:object].image_kind?
          #       "<a href='#{CGI::escapeHTML(bindings[:object].file.url)}'><img src='#{CGI::escapeHTML(bindings[:object].file.url)}' /></a>".html_safe.freeze
          #     else
          #       value
          #     end
          #   end
          # end
          # field :raw_array do
          #   weight 9
          #   searchable true
          #   pretty_value do
          #     (bindings[:object].raw_array || []).join("<br>").html_safe
          #   end
          # end
          # field :raw_hash do
          #   weight 10
          #   searchable true
          #   pretty_value do
          #     "<pre>#{JSON.pretty_generate(bindings[:object].raw_hash || {})}</pre>".html_safe
          #   end
          # end
          field :cache_keys_str, :text do
            weight 11
            searchable true
          end
          if ::Settings.table_exists?
            nss = ::RailsAdminSettings::Setting.distinct(:ns).map { |c|
              next if c =~ /^rails_admin_model_settings_/ and defined?(RailsAdminModelSettings)
              "ns_#{c.gsub('-', '_')}".to_sym
            }.compact
          else
            nss = []
          end
          if defined?(RailsAdminModelSettings)
            scopes([:no_model_settings, :model_settings, nil] + nss)
          else
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
          field :loadable, :toggle do
            weight 2
            visible do
              render_object = (bindings[:controller] || bindings[:view])
              render_object and (render_object.current_user.admin?)
            end
          end
          field :for_admin, :toggle do
            weight 3
            visible do
              render_object = (bindings[:controller] || bindings[:view])
              render_object and (render_object.current_user.admin?)
            end
          end
          field :ns  do
            weight 4
            read_only true
            help false
            visible do
              render_object = (bindings[:controller] || bindings[:view])
              render_object and (render_object.current_user.admin?)
            end
          end
          field :key  do
            weight 5
            read_only true
            help false
            visible do
              render_object = (bindings[:controller] || bindings[:view])
              render_object and (render_object.current_user.admin?)
            end
          end
          field :label, :string do
            weight 6
            read_only do
              render_object = (bindings[:controller] || bindings[:view])
              !render_object or !(render_object.current_user.admin?)
            end
            help false
          end
          field :kind, :enum do
            weight 7
            read_only do
              render_object = (bindings[:controller] || bindings[:view])
              !render_object or !(render_object.current_user.admin?)
            end
            enum do
              RailsAdminSettings.kinds
            end
            partial "enum_for_settings_kinds".freeze
            help false
          end
          field :raw do
            weight 8
            partial "setting_value".freeze
            visible do
              !bindings[:object].upload_kind? and !bindings[:object].array_kind?
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
          field :raw_array do
            weight 9
            partial "setting_value".freeze
            visible do
              bindings[:object].array_kind?
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
          field :raw_hash do
            weight 10
            partial "setting_value".freeze
            visible do
              bindings[:object].hash_kind?
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
              weight 11
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
