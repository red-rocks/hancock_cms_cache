require 'rails/generators'

module Hancock::Cache::Models
  class DecoratorsGenerator < Rails::Generators::Base
    source_root File.expand_path('../../../../../../app/models/concerns/hancock/cache/decorators', __FILE__)
    argument :models, type: :array, default: []

    desc 'Hancock::Cache Models decorators generator'
    def decorators
      copied = false
      (models == ['all'] ? permitted_models : models & permitted_models).each do |c|
        copied = true
        copy_file "#{c}.rb", "app/models/concerns/hancock/cache/decorators/#{c}.rb"
      end
      puts "U need to set models`s name. One of this: #{permitted_models.join(", ")}." unless copied
    end

    private
    def permitted_models
      ['fragment']
    end

  end
end
