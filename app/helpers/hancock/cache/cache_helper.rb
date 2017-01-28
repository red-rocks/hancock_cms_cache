module Hancock
  module Cache
    module CacheHelper

      def hancock_cache(obj = [], options = nil, &block)
        if obj.is_a?(String) or obj.is_a?(Symbol)
          return hancock_fragment_cache obj.to_s, (options || {}).merge(skip_digest: true), &block

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

        if Hancock::Cache.config.model_settings_support
          _detect_cache = Hancock::Cache::Fragment.settings.detecting || Hancock::Cache.config.runtime_cache_detector
        else
          _detect_cache = Settings.hancock_cache_detecting || Hancock::Cache.config.runtime_cache_detector
        end

        if respond_to?(:hancock_cache_fragments)
          frag = hancock_cache_fragments[Hancock::Cache::Fragment.name_from_view(name)]
          parents = lookup_context.hancock_cache_keys.map do |_name|
            hancock_cache_fragments[Hancock::Cache::Fragment.name_from_view(_name)]
          end.compact
          if frag
            frag.set_for_object(for_object) if for_object
            frag.set_for_objects(for_objects) if for_objects
            frag.set_for_model(for_model) if for_model
            frag.set_for_setting(for_setting) if for_setting
          else
            if _detect_cache
              _name = Hancock::Cache::Fragment.name_from_view(name)
              _desc = "" #"#{@virtual_path}\noptions: #{options}"
              _virtual_path = @virtual_path
              Hancock::Cache::Fragment.create_unless_exists(name: _name, desc: _desc, virtual_path: _virtual_path, parents: parents)
              Hancock::Cache::Fragment.reload!
            end
          end
          condition = (frag and frag.enabled)
        else
          if _detect_cache
            parents = Hancock::Cache::Fragment.by_name_from_view(lookup_context.hancock_cache_keys).to_a
            _name = Hancock::Cache::Fragment.name_from_view(name)
            _desc = "" #"#{@virtual_path}\noptions: #{options}"
            _virtual_path = @virtual_path
            Hancock::Cache::Fragment.create_unless_exists(name: _name, desc: _desc, virtual_path: _virtual_path, parents: parents)
            Hancock::Cache::Fragment.reload!
          end
          condition = Hancock::Cache::Fragment.enabled.by_name_from_view(name).count > 0
        end
        lookup_context.hancock_cache_keys << name
        ret = cache_if condition, name, options, &block
        lookup_context.hancock_cache_keys.delete(name)
        return ret
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

      def hancock_cache_keys
        lookup_context.hancock_cache_keys.dup.freeze
      end

    end
  end
end
module Hancock
  module Cache
    module CacheHelper

      def hancock_cache(obj = [], options = nil, &block)
        if obj.is_a?(String) or obj.is_a?(Symbol)
          return hancock_fragment_cache obj.to_s, (options || {}).merge(skip_digest: true), &block

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

        _detect_cache = Hancock::Cache::Fragment.settings.detecting || Hancock::Cache.config.runtime_cache_detector

        if respond_to?(:hancock_cache_fragments)
          frag = hancock_cache_fragments[Hancock::Cache::Fragment.name_from_view(name)]
          parents = lookup_context.hancock_cache_keys.map do |_name|
            hancock_cache_fragments[Hancock::Cache::Fragment.name_from_view(_name)]
          end.compact
          if frag
            frag.set_for_object(for_object) if for_object
            frag.set_for_objects(for_objects) if for_objects
            frag.set_for_model(for_model) if for_model
            frag.set_for_setting(for_setting) if for_setting
          else
            if _detect_cache
              _name = Hancock::Cache::Fragment.name_from_view(name)
              _desc = "" #"#{@virtual_path}\noptions: #{options}"
              _virtual_path = @virtual_path
              Hancock::Cache::Fragment.create_unless_exists(name: _name, desc: _desc, virtual_path: _virtual_path, parents: parents)
              Hancock::Cache::Fragment.reload!
            end
          end
          condition = (frag and frag.enabled)
        else
          if _detect_cache
            parents = Hancock::Cache::Fragment.by_name_from_view(lookup_context.hancock_cache_keys).to_a
            _name = Hancock::Cache::Fragment.name_from_view(name)
            _desc = "" #"#{@virtual_path}\noptions: #{options}"
            _virtual_path = @virtual_path
            Hancock::Cache::Fragment.create_unless_exists(name: _name, desc: _desc, virtual_path: _virtual_path, parents: parents)
            Hancock::Cache::Fragment.reload!
          end
          condition = Hancock::Cache::Fragment.enabled.by_name_from_view(name).count > 0
        end
        lookup_context.hancock_cache_keys << name
        ret = cache_if condition, name, options, &block
        lookup_context.hancock_cache_keys.delete(name)
        return ret
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

      def hancock_cache_keys
        lookup_context.hancock_cache_keys.dup.freeze
      end

    end
  end
end
