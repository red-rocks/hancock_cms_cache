
module ActionView
  module Helpers
    module CacheHelper

      def cache_fragment_name(name = {}, options = nil)
        skip_digest = options && options[:skip_digest]

        if skip_digest
          begin
            if Hancock::Cache.config.runtime_cache_detector
              _name = Hancock::Cache::Fragment.name_from_view(name)
              _desc = "#{@virtual_path}\noptions: #{options}"
              Hancock::Cache::Fragment.create_unless_exists(name: _name, desc: _desc)
            end
          rescue
          end

          name
        else
          fragment_name_with_digest(name)
        end
      end

    end
  end
end
