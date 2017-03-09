module Hancock
  module Cache
    module CacheHelper

      def hancock_cache_settings(key, options = {}, &block)
        if key.is_a?(Hash)
          key, options = key[:key], key
        end

        cache_keys = options[:cache_keys_str] || options[:cache_keys] || options[:cache_key] || []
        if cache_keys.is_a?(::Array)
          cache_keys = cache_keys.map { |k| k.to_s.strip }.join(" ")
        else
          cache_keys = cache_keys.to_s.strip
        end
        options.delete(:cache_keys)
        options.delete(:cache_key)
        options[:cache_keys_str] = [cache_keys, hancock_cache_views_keys].flatten.map { |k| k.to_s.strip }.reject(&:blank?).join(" ").strip

        hancock_settings(key, options, &block)
      end


      def hancock_cache(obj = [], options = {}, &block)
        if obj.is_a?(String) or obj.is_a?(Symbol)
          return hancock_fragment_cache obj.to_s, (options || {}).merge(skip_digest: true), &block

        else
          condition = Array(obj).map { |o|
            !o.respond_to?(:perform_caching) or o.perform_caching
          }

          if obj.respond_to?(:cache_keys_str) and obj.respond_to?(:cache_keys) and obj.respond_to?(:cache_keys=)
            obj.cache_keys |= hancock_cache_views_keys
            obj.save if obj.cache_keys_str_changed?
          end

          condition = (condition.blank? or condition.uniq == [true])
          cache_if condition, obj, options, &block
        end
      end
      def hancock_cache_unless(condition, obj = [], options = {}, &block)
        hancock_cache_if !condition, obj, options, &block
      end
      def hancock_cache_if(condition, obj = [], options = {}, &block)
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
        _on_ram     = (options and options.delete(:on_ram))

        # if Hancock::Cache.config.model_settings_support
        #   _detect_cache = !!(Hancock::Cache.config.runtime_cache_detector || Hancock::Cache::Fragment.settings.detecting)
        # else
        #   _detect_cache = !!(Hancock::Cache.config.runtime_cache_detector || Settings.hancock_cache_detecting)
        # end
        _detect_cache = true

        if respond_to?(:hancock_cache_fragments)
          frag = hancock_cache_fragments[Hancock::Cache::Fragment.name_from_view(name)]
          # parents = hancock_cache_keys.map do |_name|
          #   hancock_cache_fragments[Hancock::Cache::Fragment.name_from_view(_name)]
          # end.compact
          parent_names = hancock_cache_views_keys
          if frag
            frag.set_for_object(for_object) if for_object
            frag.set_for_objects(for_objects) if for_objects
            frag.set_for_model(for_model) if for_model
            frag.set_for_setting(for_setting) if for_setting
            if _detect_cache
              frag.parent_names |= parent_names
              if frag.parent_names_changed?
                # frag.set_parent_ids! and hancock_cache_fragments[frag.name] = frag
                frag.update_parent_ids! and hancock_cache_fragments[frag.name] = frag.reload
              end
            end
          else
            if _detect_cache
              _name = Hancock::Cache::Fragment.name_from_view(name)
              _desc = "" #"#{@virtual_path}\noptions: #{options}"
              _virtual_path = @virtual_path
              # Hancock::Cache::Fragment.create_unless_exists(name: _name, desc: _desc, virtual_path: _virtual_path, parents: parents)
              Hancock::Cache::Fragment.create_unless_exists(name: _name, desc: _desc, virtual_path: _virtual_path, parent_names: parent_names, on_ram: _on_ram)
              Hancock::Cache::Fragment.reload!
              frag = hancock_cache_fragments[_name]
            end
          end
          condition = (frag and frag.enabled)
        else
          if _detect_cache
            # parents = Hancock::Cache::Fragment.by_name_from_view(hancock_cache_keys).to_a
            # _name = Hancock::Cache::Fragment.name_from_view(name)
            # _desc = "" #"#{@virtual_path}\noptions: #{options}"
            # _virtual_path = @virtual_path
            # Hancock::Cache::Fragment.create_unless_exists(name: _name, desc: _desc, virtual_path: _virtual_path, parents: parents)
            # Hancock::Cache::Fragment.reload!
            # frag.parent_names |= parent_names
            # if frag.parent_names_changed?
            #   # frag.set_parent_ids! and hancock_cache_fragments[frag.name] = frag
            #   frag.update_parent_ids! and hancock_cache_fragments[frag.name] = frag
            # end
          end
          condition = Hancock::Cache::Fragment.enabled.by_name_from_view(name).count > 0
        end
        if frag and frag.on_ram and !frag.on_ram_data.nil?
          ret = frag.on_ram_data
        else
          lookup_context.hancock_cache_keys << name
          ret = cache_if condition, name, options, &block
          frag.on_ram_data = ret if frag and frag.on_ram
          lookup_context.hancock_cache_keys.delete(name)
        end
        return ret
      end
      def hancock_fragment_cache_unless(condition, obj = [], options = {}, &block)
        hancock_fragment_cache_if !condition, obj, options, &block
      end
      def hancock_fragment_cache_if(condition, obj = [], options = {}, &block)
        if condition
          hancock_fragment_cache obj, options, &block
        else
          yield
        end
        nil
      end

      def hancock_cache_keys
        ret = lookup_context.hancock_cache_keys.dup

        if respond_to?(:page_cache_key) and !page_cache_key.blank?
          if (!respond_to?(:page_cache_obj) or page_cache_obj.nil?)
            _name = page_cache_key
            _desc = <<-TEXT
              action caching
              controller: #{controller_name}
              action: #{action_name}
              params: #{params.inspect}
            TEXT
            Hancock::Cache::Fragment.create_unless_exists(name: Hancock::Cache::Fragment.name_from_view(_name), desc: _desc)
          end
          ret.unshift page_cache_key
        end

        ret.uniq.freeze
      end

      def hancock_cache_views_keys
        hancock_cache_keys.map { |k| Hancock::Cache::Fragment.name_from_view(k) }
      end

    end
  end
end
