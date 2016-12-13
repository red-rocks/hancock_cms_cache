module Hancock::Cache
  module Admin
    module Fragment
      def self.config(fields = {})
        Proc.new {
          navigation_label I18n.t('hancock.cache')

          field :name do
            searchable true
          end
          field :clear, :hancock_cache_clear do
            searchable false
          end
          field :desc do
            searchable true
          end
          field :last_clear_time do
            searchable false
            read_only true
          end
          field :last_clear_user do
            searchable false
            read_only true
          end
        }

      end #def self.config(fields = {})

    end #module Fragment
  end #module Admin
end #module Hancock::Cache
