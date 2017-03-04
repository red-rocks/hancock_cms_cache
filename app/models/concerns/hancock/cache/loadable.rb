module Hancock::Cache::Loadable
  extend ActiveSupport::Concern

  included do
    cattr_reader :loaded_info, :loaded
    @@loaded = false
    @@load_mutex = Mutex.new

    class << self
      def unload!
        @@load_mutex.synchronize do
          @@loaded_info = {}
          @@loaded = false
        end
      end

      def load!
        @@load_mutex.synchronize do
          return if @@loaded
          @@loaded_info = Hancock::Cache::Fragment.cutted.all.to_a.map { |f| f.load_data_on_ram; [f.name, f] }.to_h
          @@loaded = true
        end
      end

      def reload!
        unload!
        load!
      end

      def [](key)
        @@loaded_info[key]
      end
    end

    def reload_info!
      self.class.reload!
    end

    after_save :reload_info!
    after_destroy :reload_info!

  end

end
