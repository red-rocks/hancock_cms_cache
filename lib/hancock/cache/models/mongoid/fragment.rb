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

        def data(prettify = true)
          _data = Rails.cache.read(self.name)
          prettify ? "<pre>#{CGI::escapeHTML(Nokogiri::HTML.fragment(_data).to_xhtml(indent: 2))}</pre>".html_safe : _data
        end

        def set_last_clear_user(forced_user = nil)
          unless forced_user
            return false unless Mongoid::Userstamp.has_current_user?
            self.last_clear_user = Mongoid::Userstamp.current_user
          else
            self.last_clear_user = forced_user
          end
        end

        def self.set_for_object(key_name, obj)
          _frag = self.where(name: key_name).first
          _frag and _frag.set_for_object obj
        end
        def self.set_for_objects(_class)
          _frag = self.where(name: key_name).first
          _frag and _frag.set_for_objects _class
        end
        def set_for_object(obj)
          if obj.is_a?(Hash)
            if obj[:model].present?
              if obj[:ids].present?
                return obj[:ids].map do |_id|
                  set_for_setting({model: obj[:model], id: obj[:id]})
                end
              else
                if obj[:id].nil?
                  return set_for_objects(obj[:model])
                else
                  obj = obj[:model].where(id: obj[:id]).first
                end
              end
            else
              return false
            end

          elsif obj.is_a?(Array)
            return obj.map do |_obj|
              set_for_object(_obj)
            end
          end

          if obj
            if obj.is_a?(Class)
              set_for_objects obj
            else
              obj.cache_keys << self.name
              obj.save
            end
          end
        end
        def set_for_objects(_class)
          _class.all.map { |obj|
            obj.cache_keys << self.name
            obj.save
          }
        end

        def self.set_for_setting(key_name, setting_obj)
          _frag = self.where(name: key_name).first
          _frag and _frag.set_for_setting setting_obj
        end
        def set_for_setting(setting_obj)
          if defined?(RailsAdminModelSettings)
            if setting_obj.is_a?(Hash)
              unless setting_obj[:keys].present?
                if setting_obj[:key].nil?
                  return set_for_setting({ns: setting_obj[:ns], key: //})
                else
                  setting_obj = RailsAdminSettings::Setting.where(ns: setting_obj[:ns], key: setting_obj[:key]).first
                end

              else
                return setting_obj[:keys].map do |k|
                  set_for_setting({ns: setting_obj[:ns], key: k})
                end
              end

            elsif setting_obj.is_a?(Array)
              return setting_obj.map do |obj|
                set_for_setting(obj)
              end
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
