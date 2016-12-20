require "hancock/cache/version"
require 'hancock/cache/engine'
require 'hancock/cache/configuration'

require 'hancock/cache/admin'

require 'hancock/cache/rails_admin_ext/hancock_cache_clear'
require 'hancock/cache/rails_admin_ext/hancock_cache_global_clear'
require 'hancock/cache/rails_admin_ext/hancock_cache_get_snapshot'
require 'hancock/cache/rails_admin_ext/hancock_touch'

require 'hancock/cache/rails_admin_settings_patch'

module Hancock::Cache
  include Hancock::Plugin

  autoload :Admin,  'hancock/cache/admin'
  module Admin
    autoload :Fragment,       'hancock/cache/admin/fragment'
  end

  module Models
    autoload :Fragment,       'hancock/cache/models/fragment'

    module Mongoid
      autoload :Fragment,       'hancock/cache/models/mongoid/fragment'
    end

    # module ActiveRecord
    #   autoload :Fragment,       'hancock/cache/models/active_record/fragment'
    # end
  end
end
