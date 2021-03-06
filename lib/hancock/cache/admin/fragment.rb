module Hancock::Cache
  module Admin
    module Fragment
      def self.config(fields = {})
        Proc.new {
          navigation_label I18n.t('hancock.cache')

          list do
            field :enabled, :toggle
            field :is_action_cache do
              read_only true
            end

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

            field :data do
              pretty_value do
                bindings[:object].data(false)
              end
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

            field :on_ram, :toggle
            field :is_html, :toggle
            field :virtual_path do
              searchable true
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

            scopes [nil, :is_action_cache, :on_ram]
          end

          edit do
            field :enabled, :toggle
            field :is_action_cache do
              read_only true
            end
            field :on_ram, :toggle
            field :name
            field :virtual_path
            field :is_html, :toggle
            field :desc
            field :parents, :hancock_multiselect
            field :all_parents do
              read_only true
              pretty_value do
                bindings[:object].all_parents.map do |p|
                  bindings[:view].link_to(
                    p.name,
                    bindings[:view].hancock_show_path(p),
                  )
                end.join(", ").html_safe
              end
            end

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

            Hancock::RailsAdminGroupPatch::hancock_cms_group(self, fields)
          end

          show do
            field :enabled, :toggle
            field :is_action_cache do
              read_only true
            end
            field :on_ram, :toggle
            field :name
            field :virtual_path
            field :is_html
            field :desc
            field :parents
            field :all_parents do
              read_only true
              pretty_value do
                bindings[:object].all_parents.map do |p|
                  bindings[:view].link_to(
                    p.name,
                    bindings[:view].hancock_show_path(p),
                  )
                end.join(", ").html_safe
              end
            end
            field :parent_names do
              visible do
                render_object = (bindings[:controller] || bindings[:view])
                (render_object and render_object.current_user.admin?)
              end
            end
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

            Hancock::RailsAdminGroupPatch::hancock_cms_group(self, fields)
          end

          if block_given?
            yield self
          end
        }

      end #def self.config(fields = {})

    end #module Fragment
  end #module Admin
end #module Hancock::Cache
