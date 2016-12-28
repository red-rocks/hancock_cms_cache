module Hancock
  module Cache
    class Engine < ::Rails::Engine
      # isolate_namespace Hancock::Cache

      initializer "RailsAdminSettingsPatch (cache)" do
        if defined?(RailsAdminSettings)
          ::RailsAdminSettings::Setting.send(:include, Hancock::Cache::RailsAdminSettingsPatch)
        end
      end

    end
  end
end
