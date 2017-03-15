require 'rails_admin/config/actions'

module RailsAdmin
  module Config
    module Actions
      class HancockCacheClear < Base
        RailsAdmin::Config::Actions.register(self)

        # Is the action acting on the root level (Example: /admin/contact)
        register_instance_option :root? do
          false
        end

        register_instance_option :collection? do
          false
        end

        # Is the action on an object scope (Example: /admin/team/1/edit)
        register_instance_option :member? do
          true
        end

        register_instance_option :controller do
          proc do
            ajax_link = Proc.new do |fv, badge|
              # can_edit_obj = can?(:edit, @object)
              # render json: {
              #   text: fv.html_safe,
              #   href: hancock_cache_clear_path(model_name: @abstract_model, id: @object.id),
              #   class: 'label ' + badge,
              #   url: index_path(model_name: @abstract_model)
              # }
            end
            if params['id'].present?
              begin
                @object = @abstract_model.model.unscoped.find(params['id'])
                if @object.clear!
                  if params['ajax'].present?
                    ajax_link.call('♻', 'label-success')
                  else
                    flash[:success] = I18n.t('admin.hancock_cache_clear.cleared', obj: @object, name: @object.name)
                    unless @object.parents.blank?
                      flash[:info] = "Также, возможно необходимо сбросить кеш с этми ключами: #{@object.parents_str}"
                    end
                  end
                else
                  if params['ajax'].present?
                    render plain: @object.errors.full_messages.join(', '), layout: false, status: 422
                  else
                    flash[:error] = @object.errors.full_messages.join(', ')
                  end
                end
              rescue Exception => e
                if params['ajax'].present?
                  render plain: I18n.t('admin.hancock_cache_clear.error', err: e.to_s), status: 422
                else
                  flash[:error] = I18n.t('admin.hancock_cache_clear.error', err: e.to_s)
                end
              end
            else
              if params['ajax'].present?
                render plain: I18n.t('admin.hancock_cache_clear.no_id'), status: 422
              else
                flash[:error] = I18n.t('admin.hancock_cache_clear.no_id')
              end
            end

            unless params['ajax'].present?
              begin
                fallback_location = index_path(model_name: @abstract_model, id: @object.id)
              rescue
                fallback_location = index_path(model_name: @abstract_model)
              end
              redirect_back(fallback_location: fallback_location)
            end

          end
        end

        register_instance_option :link_icon do
          'icon-trash'
        end

        register_instance_option :pjax? do
          false
        end

        register_instance_option :http_methods do
          [:get]
        end

      end
    end
  end
end
