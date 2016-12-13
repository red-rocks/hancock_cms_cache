require 'rails/generators'

module Hancock::Cache
  class ConfigGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    desc 'Hancock::Cache Config generator'
    def config
      template 'hancock_cache.erb', "config/initializers/hancock_cache.rb"
    end

  end
end
