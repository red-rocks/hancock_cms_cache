module Hancock
  module Cache
    module CacheHelper

      def hancock_cache(obj = [], options = nil, &block)
        if obj.is_a?(String) or obj.is_a?(Symbol)
          return hancock_fragment_cache obj, (options || {}).merge(skip_digest: true), &block

        else
          condition = Array(obj).map { |o|
            !o.respond_to?(:perform_caching) or o.perform_caching
          }
          condition = (condition.blank? or condition.uniq == [true])
          cache_if condition, obj, options, &block
        end
      end
      def hancock_cache_unless(condition, obj = [], options = nil, &block)
        hancock_cache_if !condition, obj, options, &block
      end
      def hancock_cache_if(condition, obj = [], options = nil, &block)
        if condition
          hancock_cache obj, options, &block
        else
          yield
        end
        nil
      end

      def hancock_fragment_cache(name = '', options = {}, &block)
        for_object  = (options and options.delete(:for_object))
        for_objects = (options and options.delete(:for_objects))
        for_model   = (options and options.delete(:for_model))
        for_setting = (options and options.delete(:for_setting))

        if respond_to?(:hancock_cache_fragments)
          frag = hancock_cache_fragments[Hancock::Cache::Fragment.name_from_view(name)]
          if frag
            frag.set_for_object(for_object) if for_object
            frag.set_for_objects(for_objects) if for_objects
            frag.set_for_model(for_model) if for_model
            frag.set_for_setting(for_setting) if for_setting
          end
          condition = (frag and frag.enabled)
        else
          condition = Hancock::Cache::Fragment.enabled.by_name_from_view(name).count > 0
        end
        cache_if condition, name, options, &block
      end
      def hancock_fragment_cache_unless(condition, obj = [], options = nil, &block)
        hancock_fragment_cache_if !condition, obj, options, &block
      end
      def hancock_fragment_cache_if(condition, obj = [], options = nil, &block)
        if condition
          hancock_fragment_cache obj, options, &block
        else
          yield
        end
        nil
      end

    end
  end
end
