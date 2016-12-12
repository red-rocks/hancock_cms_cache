
module ActionView
  module Helpers
    module CacheHelper

      def cache_fragment_name(name = {}, options = nil)
        skip_digest = options && options[:skip_digest]

        if skip_digest
          _name = Hancock::Cache::Fragment.name_from_view(name)
          _f = Hancock::Cache::Fragment.where(name: _name).first
          Hancock::Cache::Fragment.create(name: _name, desc: options) unless _f
          name
        else
          fragment_name_with_digest(name)
        end
      end

    end
  end
end
