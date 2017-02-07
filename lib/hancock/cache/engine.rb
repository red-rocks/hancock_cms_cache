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

    end
  end
end
