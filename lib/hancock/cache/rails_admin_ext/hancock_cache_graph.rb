require 'rails_admin/config/actions'

module RailsAdmin
  module Config
    module Actions
      class HancockCacheGraph < Base
        RailsAdmin::Config::Actions.register(self)

        # Is the action acting on the root level (Example: /admin/contact)
        register_instance_option :root? do
          false
        end

        register_instance_option :collection? do
          true
        end

        # Is the action on an object scope (Example: /admin/team/1/edit)
        register_instance_option :member? do
          false
        end

        register_instance_option :route_fragment do
          'graph'
        end

        register_instance_option :controller do
          Proc.new do |klass|
            # @config = ::HancockCacheGlobalClear::Configuration.new @abstract_model
            if request.get?

              model = @abstract_model.model
              model_str = model.name.underscore
              nodes = model.all.to_a

              @nodes_for_vis = nodes.map { |n|
                _label = n.name.split("/")
                size = _label.size * 10
                size = n.name.size if n.name.size > size
                {
                  id: n.id.to_s,
                  label: _label.join("\n"),
                  size: size,
                  shape: (n.is_action_cache ? 'square' : 'circle'),
                  doubleClick: "window.open('#{show_path(model_name: @abstract_model, id: n.id)}', '_blank').focus();"
                }
              }.to_json
              @edges_for_vis = nodes.map { |n|
                ret = []
                ret += nodes.select { |nn| n.parent_ids.include?(nn.id) }.map { |nn|
                  {
                    from: n.id.to_s,
                    to: nn.id.to_s,
                    arrows: 'to'
                  }
                }
                ret += nodes.select { |nn| n.parent_names.include?(nn.name) }.map { |nn|
                  next unless ret.select { |r| r[:from] == n.id.to_s and r[:to] == nn.id.to_s }.blank?
                  {
                    from: n.id.to_s,
                    to: nn.id.to_s,
                    arrows: 'to',
                    dashes: true
                  }
                }.compact
                ret.flatten
              }.flatten.to_json

              render action: @action.template_name

            elsif request.post?

            end
          end
        end

        register_instance_option :link_icon do
          'fa fa-code-fork'
        end

        register_instance_option :http_methods do
          [:get, :post]
        end

      end
    end
  end
end
