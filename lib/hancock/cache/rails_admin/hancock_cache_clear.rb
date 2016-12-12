require 'rails_admin/config/actions'
require 'rails_admin/config/model'

require "rails_admin_toggleable"

module RailsAdmin
  module Config
    module Actions
      class HancockCacheClear < Toggle
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :controller do
          proc do
            ajax_link = Proc.new do |fv, badge|
              # can_edit_obj = can?(:edit, @object)
              render json: {
                text: fv.html_safe,
                href: hancock_cache_clear_path(model_name: @abstract_model, id: @object.id),
                class: 'label ' + badge,
                url: index_path(model_name: @abstract_model)
              }
            end
            if params['id'].present?
              begin
                @object = @abstract_model.model.unscoped.find(params['id'])
                if @object.clear!
                  if params['ajax'].present?
                    ajax_link.call('♻', 'label-success')
                  else
                    flash[:success] = I18n.t('admin.hancock_cache_clear.cleared', obj: @object)
                  end
                else
                  if params['ajax'].present?
                    render text: @object.errors.full_messages.join(', '), layout: false, status: 422
                  else
                    flash[:error] = @object.errors.full_messages.join(', ')
                  end
                end
              rescue Exception => e
                if params['ajax'].present?
                  render text: I18n.t('admin.hancock_cache_clear.error', err: e.to_s), status: 422
                else
                  flash[:error] = I18n.t('admin.hancock_cache_clear.error', err: e.to_s)
                end
              end
            else
              if params['ajax'].present?
                render text: I18n.t('admin.hancock_cache_clear.no_id'), status: 422
              else
                flash[:error] = I18n.t('admin.hancock_cache_clear.no_id')
              end

            end

            redirect_to :back unless params['ajax'].present?
          end
        end

      end
    end
  end
end

module RailsAdmin
  module Config
    module Fields
      module Types
        class HancockCacheClear < Toggle
          # Register field type for the type loader
          RailsAdmin::Config::Fields::Types::register(self)
          include RailsAdmin::Engine.routes.url_helpers

          register_instance_option :pretty_value do
            def g_js
              <<-END.strip_heredoc.gsub("\n", ' ').gsub(/ +/, ' ')
                var $t = $(this);
                $t.html("<i class='fa fa-spinner fa-spin'></i>");
                $.ajax({
                  type: "POST",
                  url: $t.attr("href"),
                  data: {ajax:true},
                  success: function(r) {
                    $t.attr("href", r.href);
                    $t.attr("class", r.class);
                    $t.text(r.text);
                    $t.parent().attr("title", r.text);
                    $t.siblings(".hancock-cache-clear-btn").remove();
                    //window.location.replace(r.url);
                  },
                  error: function(e) {
                    alert(e.responseText);
                  }
                });
                return false;
              END
            end
            def g_link(fv, badge)
              if read_only
                bindings[:view].content_tag(:span,
                  "♻",
                  class: 'hancock-cache-clear-btn label label-info'
                )
              else
                bindings[:view].link_to(
                  fv.html_safe,
                  hancock_cache_clear_path(model_name: @abstract_model, id: bindings[:object].id),
                  method: :post,
                  class: 'hancock-cache-clear-btn label ' + badge,
                  onclick: g_js
                )
              end
            end

            g_link('♻', 'label-success').html_safe

            # case value
            #   when nil
            #     # %{<span class="label">-</span>}
            #     g_link('✓', 'label-success')
            #     # g_link('✘', 0, 'label-danger') + ' ' + g_link('✓', 1, 'label-success')
            #   when true #false
            #     # g_link('✘', 1, 'label-danger')
            #     g_link('✓', 'label-success')
            #   when false #true
            #     # g_link('✓', 0, 'label-success')
            #     g_link('✓', 'label-success')
            #   else
            #     %{<span class="label">-</span>}
            # end.html_safe
          end

          register_instance_option :value do
            '✓'
          end

          register_instance_option :export_value do
            nil
          end

          # Accessor for field's help text displayed below input field.
          register_instance_option :help do
            ""
          end
        end
      end
    end
  end
end
