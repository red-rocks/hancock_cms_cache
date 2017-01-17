module Hancock::Cache::Decorators
  module Fragment
    extend ActiveSupport::Concern

    included do

      ############# rails_admin ##############
      # def self.rails_admin_name_synonyms
      #   "Кеш Кэш".freeze
      # end
      # def self.rails_admin_navigation_icon
      #   ''.freeze
      # end
      #
      # def self.rails_admin_add_fields
      #   [].freeze #super
      # end
      #
      # def self.rails_admin_add_config(config)
      #   #super(config)
      # end
      #
      # def self.admin_can_user_defined_actions
      #   [].freeze
      # end
      # def self.admin_cannot_user_defined_actions
      #   [].freeze
      # end
      # def self.manager_can_user_defined_actions
      #   [].freeze
      # end
      # def self.manager_cannot_user_defined_actions
      #   [].freeze
      # end
      # def self.rails_admin_user_defined_visible_actions
      #   [].freeze
      # end
    end

  end
end
