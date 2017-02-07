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

    helper_method :page_cache_key, :page_cache_obj
  end

end
