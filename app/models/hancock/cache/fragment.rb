module Hancock::Cache
  class Fragment
    include Hancock::Cache::Models::Fragment

    include Hancock::Cache::Decorators::Fragment

    rails_admin(&Hancock::Cache::Admin::Fragment.config(rails_admin_add_fields) { |config|
      rails_admin_add_config(config)
    })
  end
end
