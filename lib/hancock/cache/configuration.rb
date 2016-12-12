module Hancock::Cache
  include Hancock::PluginConfiguration

  def self.config_class
    Configuration
  end

  class Configuration

    attr_accessor :localize

    def initialize

      @localize = Hancock.config.localize

    end
  end
end
