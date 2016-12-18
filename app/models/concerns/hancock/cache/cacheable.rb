if Hancock.mongoid?

  module Hancock::Cache::Cacheable
    extend ActiveSupport::Concern

    included do
      field :cache_keys_str, type: String, default: -> { default_cache_keys.map(&:strip).join("\n") }
      def self.default_cache_keys
        []
      end
      def default_cache_keys
        self.class.default_cache_keys
      end
      def set_default_cache_keys(strategy = :append)
        _old_keys = cache_keys

        _keys = case strategy.to_sym
        when :append
          (_old_keys + default_cache_keys).uniq
        when :overwrite, :replace
          default_cache_keys
        else
          _old_keys
        end
        self
      end
      def set_default_cache_keys!(strategy = :append)
        self.set_default_cache_keys(strategy) and self.save
      end

      def conditional_cache_keys
        [{}]
      end
      def selected_conditional_cache_keys
        conditional_cache_keys and conditional_cache_keys.select { |cache_key|
          cond_if, cond_unless = cache_key[:if], cache_key[:unless]

          if cond_if
            if cond_if.is_a?(Proc)
              cond_if = !!cond_if.call
            elsif cond_if.is_a?(String)
              cond_if = !!self.instance_eval(cond_if)
            else
              cond_if = !!cond_if
            end
          else
            cond_if = true
          end

          if cond_unless
            if cond_unless.is_a?(Proc)
              cond_unless = !cond_unless.call
            elsif cond_unless.is_a?(String)
              cond_unless = !self.instance_eval(cond_unless)
            else
              cond_unless = !cond_unless
            end
          else
            cond_unless = true
          end

          cond_if and cond_unless
        } or []
      end

      def all_cache_keys
        return @all_cache_keys if @all_cache_keys
        @all_cache_keys = cache_keys || []
        @all_cache_keys += selected_conditional_cache_keys.map { |k| k[:name] }
        @all_cache_keys
      end


      def cache_keys
        return @cache_keys if @cache_keys

        def <<(_keys)
          cache_keys_str = (cache_keys + _keys).select { |k|
            k and !k.strip.blank?
          }.map(&:strip).uniq.join("\n")
          cache_keys
        end

        @cache_keys = cache_keys_str.split(/\s+/).map { |k| k.strip }.reject { |k| k.blank? }
      end
      def cache_keys=(_keys)
        cache_keys_str = _keys.select { |k|
          k and !k.strip.blank?
        }.map(&:strip).uniq.join("\n")
        cache_keys
      end
      # def cache_keys<<(_keys)
      #   cache_keys_str = (cache_keys + _keys).select { |k|
      #     k and !k.strip.blank?
      #   }.map(&:strip).uniq.join("\n")
      #   cache_keys
      # end
      field :perform_caching, type: Boolean, default: true

      after_touch :clear_cache
      after_save :clear_cache
      after_destroy :clear_cache
      def clear_cache
        if perform_caching
          # cache_keys and cache_keys.is_a?(Array) and cache_keys.each do |k|
          all_cache_keys and all_cache_keys.is_a?(Array) and all_cache_keys.each do |k|
            Rails.cache.delete(k)
          end
          # @cache_keys = nil
          @all_cache_keys = nil
        end
      end

    end
  end

end
