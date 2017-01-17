module Hancock::Cache
  module Admin
    module Fragment
      def self.config(fields = {})
        Proc.new {
          navigation_label I18n.t('hancock.cache')

          list do
            field :enabled, :toggle
            field :is_html, :toggle

            field :name_n_desc_n_parents
            # field :name_n_desc
            field :name do
              visible false
              searchable true
            end
            field :desc do
              visible false
              searchable true
            end
            field :virtual_path do
              searchable true
            end

            field :last_clear_data
            field :last_clear_time do
              visible false
              searchable false
            end
            field :last_clear_user do
              visible false
              searchable false
            end

            field :data do
              pretty_value do
                bindings[:object].data(false)
              end
            end

            field :snapshot_data
            field :snapshot do
              visible false
              searchable true
              pretty_value do
                bindings[:object].get_snapshot(false)
              end
              queryable true
            end
            field :last_dump_snapshot_time do
              visible false
            end
            field :last_restore_snapshot_time do
              visible false
            end
          end

          edit do
            field :enabled, :toggle
            field :name
            field :virtual_path
            field :is_html, :toggle
            field :desc
            field :parents, :hancock_multiselect

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
              read_only do
                render_object = (bindings[:controller] || bindings[:view])
                !(render_object and render_object.current_user.admin?)
              end
            end
            field :last_dump_snapshot_time do
              read_only true
            end
            field :last_restore_snapshot_time do
              read_only true
            end
          end

          show do
            field :enabled, :toggle
            field :name
            field :virtual_path
            field :is_html
            field :desc
            field :parents
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
