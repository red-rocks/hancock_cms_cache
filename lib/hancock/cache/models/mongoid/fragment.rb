module Hancock::Cache
  module Models::Mongoid
    module Fragment
      extend ActiveSupport::Concern

      included do
        index({name: 1}, {unique: true})
        index({last_clear_user_id: 1, last_clear_time: 1})

        field :name, type: String, localize: false, default: ""

        field :desc, type: String, localize: Hancock::Cache.config.localize, default: ""

        field :last_clear_time, type: DateTime
        if Hancock.rails4?
          belongs_to :last_clear_user, class_name: Mongoid::Userstamp.config.user_model_name, autosave: false
        else
          belongs_to :last_clear_user, class_name: Mongoid::Userstamp.config.user_model_name, autosave: false, optional: true, required: false
        end

        def set_last_clear_user(forced_user = nil)
          unless forced_user
            return false unless Mongoid::Userstamp.has_current_user?
            self.last_clear_user = Mongoid::Userstamp.current_user
          else
            self.last_clear_user = forced_user
          end
        end

      end

    end
  end
end
