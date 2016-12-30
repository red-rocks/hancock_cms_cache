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
      def self.set_default_cache_keys(strategy = :append)
        self.all.to_a.map { |obj| obj.set_default_cache_keys(strategy) }
      end
      def self.set_default_cache_keys!(strategy = :append)
        self.all.to_a.map { |obj| obj.set_default_cache_keys!(strategy) }
      end

      def conditional_cache_keys
        [{}]
      end
      def conditional_cache_keys_names
        conditional_cache_keys.map { |k| k[:name] }.compact
      end
      def selected_conditional_cache_keys
        conditional_cache_keys and conditional_cache_keys.select { |cache_key|
          false if cache_key[:name].blank?
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
      def selected_conditional_cache_keys_names
        selected_conditional_cache_keys.map { |k| k[:name] }.compact
      end

      cattr_reader :forced_cache_keys
      @forced_cache_keys = []

      def self.add_forced_cache_key(key)
        key = key.to_s
        @forced_cache_keys << key unless @forced_cache_keys.include?(key)
      end
      def forced_cache_keys
        self.class.forced_cache_keys
      end

      def all_cache_keys(cached = true)
        # return @all_cache_keys if @all_cache_keys
        if cached
          @all_cache_keys = cache_keys || []
          @all_cache_keys += (forced_cache_keys || [])
          @all_cache_keys += selected_conditional_cache_keys_names
          @all_cache_keys
        else
          (cache_keys || []) + selected_conditional_cache_keys_names
        end
      end


      def cache_keys
        # return @cache_keys if @cache_keys

        self.cache_keys_str ||= ""
        # @cache_keys = cache_keys_str.split(/\s+/).map { |k| k.strip }.reject { |k| k.blank? }
        self.cache_keys_str.split(/\s+/).map { |k| k.strip }.reject { |k| k.blank? }
      end
      def cache_keys=(_keys)
        _keys ||= []
        self.cache_keys_str = _keys.select { |k|
          k and !k.strip.blank?
        }.map(&:strip).uniq.join("\n")
        cache_keys
      end
      field :perform_caching, type: Boolean, default: true

      def cache_fragments
        Hancock::Cache::Fragment.where(:name.in => cache_keys)
      end
      def all_cache_fragments
        Hancock::Cache::Fragment.where(:name.in => all_cache_keys(false))
      end

      attr_accessor :cache_cleared

      after_touch :clear_cache
      after_save :clear_cache
      after_destroy :clear_cache
      def clear_cache
        if perform_caching and !cache_cleared
          # (cache_keys and cache_keys.is_a?(Array) and cache_keys).compact.map(&:strip).uniq.each do |k|
          (all_cache_keys and all_cache_keys.is_a?(Array) and all_cache_keys).compact.map(&:strip).uniq.each do |k|
            unless k.blank?
              k = k.strip
              if _frag = Hancock::Cache::Fragment.where(name: k).first
                _frag.clear!
              else
                Rails.cache.delete(k)
              end
            end
          end
          # @cache_keys = nil
          @all_cache_keys = nil

          cache_cleared = true
        end
      end

    end
  end

end
