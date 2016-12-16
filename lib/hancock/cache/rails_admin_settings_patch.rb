module Hancock::Cache
  module RailsAdminSettingsPatch
    extend ActiveSupport::Concern

    included do
      include Hancock::Cache::Cacheable
    end

  end
end
