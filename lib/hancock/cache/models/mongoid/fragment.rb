module Hancock::Cache
  module Models::Mongoid
    module Fragment
      extend ActiveSupport::Concern

      included do
        index({name: 1}, {unique: true, background: true})
        index({last_clear_user_id: 1, last_clear_time: 1}, {background: true})

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

        def self.set_for_setting(key_name, setting_obj)
          _frag = self.where(name: key_name).first
          _frag and _frag.set_for_setting setting_obj
        end
        def set_for_setting(setting_obj)
          if defined?(RailsAdminModelSettings)
            if setting_obj.is_a?(Hash)
              unless setting_obj[:keys].present?
                setting_obj = RailsAdminSettings::Setting.where(ns: setting_obj[:ns], key: setting_obj[:key]).first

              else
                setting_obj[:keys].each do |k|
                  set_for_setting({ns: setting_obj[:ns], key: k})
                end
                return true
              end

            elsif setting_obj.is_a?(Array)
              setting_obj.each do |obj|
                set_for_setting(obj)
              end
              return true
            end


            if setting_obj
              setting_obj.cache_keys << self.name
              setting_obj.save
            end
          end
        end

      end

    end
  end
end
