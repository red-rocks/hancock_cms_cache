module Hancock
  module Cache
    class Engine < ::Rails::Engine
      # isolate_namespace Hancock::Cache

      initializer "visjs precompile hook", group: :all do |app|
        # app.config.assets.precompile += %w(vis.js vis.css)
        app.config.assets.precompile += %w( timeline/* network/* )
        app.config.assets.precompile += %w(hancock/rails_admin/cache_graph.js hancock/rails_admin/cache_graph.css)
      end


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
