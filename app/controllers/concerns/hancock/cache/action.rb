module Hancock::Cache::Action
  extend ActiveSupport::Concern

  included do
    def page_cache_key
      "pages/#{controller_name}_#{action_name}" if (params.keys - ["controller", "action"]).blank?
    end
    def page_cache_obj
      return @page_cache_obj unless @page_cache_obj.nil?
      _name = page_cache_key
      _desc = <<-TEXT
        action caching
        controller: #{controller_name}
        action: #{action_name}
        params: #{params.inspect}
      TEXT
      @page_cache_obj = Hancock::Cache::Fragment.create_unless_exists(name: Hancock::Cache::Fragment.name_from_view(_name), desc: _desc)
    end

    def hancock_cache_fragment_stale?(name, opts = {})
      if name.is_a?(Hash)
        name, opts = name.delete(:name), name
      end
      return if name.nil?
      frag = hancock_cache_fragments[Hancock::Cache::Fragment.name_from_view(name)]
      if frag
        opts.reverse_merge!(last_modified: frag.last_clear_time, etag: frag, public: true, template: false)
        stale?(opts.compact)
      else
        true
      end
    end

    helper_method :page_cache_key, :page_cache_obj
  end

end
