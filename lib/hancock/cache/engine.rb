module Hancock
  module Cache
    class Engine < ::Rails::Engine
      # isolate_namespace Hancock::Cache

      initializer "RailsAdminSettingsPatch (cache)" do
        if defined?(RailsAdminSettings)
          ::RailsAdminSettings::Setting.send(:include, Hancock::Cache::RailsAdminSettingsPatch)
        end
      end

      initializer "LookupContext Patch" do
        ActionView::LookupContext.register_detail(:hancock_cache_keys) do
          []
        end
      end

      initializer 'CacheFragmentsDetector Setting' do
        begin
          if Settings and Settings.table_exists?
            if Hancock::Cache.config.model_settings_support
              _setting_existed = !Hancock::Cache::Fragment.settings.getnc('detecting').nil?
              unless _setting_existed
                Hancock::Cache::Fragment.settings.detecting(kind: :boolean, default: false, label: "Включить режим построения дерева кэша.", cache_keys: [])
                Hancock::Cache::Fragment.settings.unload!
                _setting = Hancock::Cache::Fragment.settings.getnc('detecting')
                if _setting
                  _setting.for_admin = true
                  _setting.perform_caching = false
                  _setting.save
                end
              end

            else
              _setting_existed = !Settings.getnc('hancock_cache_detecting').nil?
              unless _setting_existed
                Settings.hancock_cache_detecting(kind: :boolean, default: false, label: "Включить режим построения дерева кэша.", cache_keys: [])
                Settings.unload!
                _setting = Settings.getnc('hancock_cache_detecting')
                if _setting
                  _setting.for_admin = true
                  _setting.perform_caching = false
                  _setting.save
                end
              end

            end
          end
        rescue
        end
      end

    end
  end
end
