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

    attr_accessor :model_settings_support
    attr_accessor :user_abilities_support
    attr_accessor :ra_comments_support

    attr_accessor :preloaded_fragments

    def initialize

      @localize = Hancock.config.localize

      @runtime_cache_detector = false

      @model_settings_support = !!defined?(RailsAdminModelSettings)
      @user_abilities_support = !!defined?(RailsAdminUserAbilities)
      @ra_comments_support = !!defined?(RailsAdminComments)

      @preloaded_fragments = []

    end
  end
end
