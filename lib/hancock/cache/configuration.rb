module Hancock::Cache
  include Hancock::PluginConfiguration

  def self.config_class
    Configuration
  end

  def self.configure
    yield configuration
  end

  class Configuration

    attr_accessor :localize

    attr_accessor :runtime_cache_detector

    attr_accessor :preloaded_fragments

    def initialize

      @localize = Hancock.config.localize

      @runtime_cache_detector = false

      @preloaded_fragments = []

    end
  end
end
