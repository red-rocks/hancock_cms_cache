module Hancock::Cache
  module Admin
    module Fragment
      def self.config(fields = {})
        Proc.new {
          navigation_label I18n.t('hancock.cache')

          list do

            field :name do
              searchable true
            end
            field :desc do
              searchable true
            end
            field :last_clear_time do
              searchable false
            end
            field :last_clear_user do
              searchable false
            end
            field :data do
              pretty_value do
                bindings[:object].data(false)
              end
            end

            field :snapshot do
              searchable true
              pretty_value do
                bindings[:object].get_snapshot(false)
              end
              queryable true
            end
            field :last_dump_snapshot_time
            field :last_restore_snapshot_time
          end

          edit do
            field :name
            field :desc
            field :last_clear_time do
              read_only true
            end
            field :last_clear_user do
              read_only true
            end
            field :data do
              read_only true
            end

            field :snapshot do
              pretty_value do
                bindings[:object].get_snapshot
              end
              read_only true
            end
            field :last_dump_snapshot_time
            field :last_restore_snapshot_time
          end

          show do
            field :name
            field :desc
            field :last_clear_time
            field :last_clear_user
            field :data

            field :snapshot do
              pretty_value do
                bindings[:object].get_snapshot
              end
            end
            field :last_dump_snapshot_time
            field :last_restore_snapshot_time
          end
        }

      end #def self.config(fields = {})

    end #module Fragment
  end #module Admin
end #module Hancock::Cache
