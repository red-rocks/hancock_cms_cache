module Hancock::Cache
  module Admin

    def self.caching_block(is_active = false, options = {})
      if is_active.is_a?(Hash)
        is_active, options = (is_active[:active] || false), is_active
      end

      Proc.new {
        active is_active
        label options[:label] || I18n.t('hancock.cache')
        field :perform_caching, :toggle
        field :cache_keys_str, :text do
          searchable true
        end
        field :cache_fragments do
          read_only true
          formatted_value do
            bindings and bindings[:object] and bindings[:object].cache_fragments.all.to_a.map do |_frag|
              bindings[:view].link_to(
                _frag.name,
                bindings[:view].show_path(model_name: _frag.rails_admin_model, id: _frag.id),
              )
            end.join(", ").html_safe
          end
        end

        Hancock::RailsAdminGroupPatch::hancock_cms_group(self, options[:fields] || {})

        if block_given?
          yield self
        end
      }
    end

  end
end
