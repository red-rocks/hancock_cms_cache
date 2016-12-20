require 'rails_admin/config/actions'

module RailsAdmin
  module Config
    module Actions
      class HancockCacheGlobalClear < Base
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
          'hancock_cache_global_clear'
        end

        register_instance_option :controller do
          Proc.new do |klass|
            # @config = ::HancockCacheGlobalClear::Configuration.new @abstract_model
            if request.get?
              render action: @action.template_name

            elsif request.post?
              case params[:type]
              when "global"
                begin
                  Rails.cache.clear
                  flash[:success] = 'Весь кеш очищен'
                rescue
                  flash[:error] = 'Ошибка'
                end
              when "fragments"
                begin
                  Hancock::Cache::Fragment.cutted.all.to_a.map do |f|
                    f.clear!
                  end
                  flash[:success] = 'Кеш очищен'
                rescue
                  flash[:error] = 'Ошибка'
                end
              else
                flash[:error] = 'Неверно указан тип кеша для сброса'
              end

              redirect_to hancock_cache_global_clear_path(model_name: 'hancock~cache~fragment'.freeze)

            end
          end
        end

        register_instance_option :link_icon do
          'icon-refresh'
        end

        register_instance_option :http_methods do
          [:get, :post]
        end

      end
    end
  end
end
