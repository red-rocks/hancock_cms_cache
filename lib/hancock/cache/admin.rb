module Hancock::Cache
  module Admin

    def self.caching_block(is_active = false)
      Proc.new {
        active is_active
        label I18n.t('hancock.cache')
        field :perform_caching, :toggle
        field :cache_keys_str, :text

        if block_given?
          yield self
        end
      }
    end
    
  end
end
