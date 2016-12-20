module Hancock::Cache
  module Models::Mongoid
    module Fragment
      extend ActiveSupport::Concern

      included do

        scope :cutted, -> {
          without(:snapshot, :last_snapshot_time)
        }

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

        field :last_snapshot_time, type: DateTime
        field :snapshot, type: String, localize: false
        def get_snapshot(prettify = true)
          _data = self.snapshot || ""
          (prettify ? "<pre>#{CGI::escapeHTML(Nokogiri::HTML.fragment(_data).to_xhtml(indent: 2))}</pre>".html_safe : _data)
        end
        def write_snapshot
          self.snapshot = self.data(false)
        end
        def write_snapshot!
          self.write_snapshot
          self.last_snapshot_time = Time.new
          self.save
        end

        def data(prettify = true)
          _data = Rails.cache.read(self.name)
          (prettify ? "<pre>#{CGI::escapeHTML(Nokogiri::HTML.fragment(_data).to_xhtml(indent: 2))}</pre>".html_safe : _data)
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
          if key_name.is_a?(Array)
            return key_name.map do |k|
              set_for_object(k, obj)
            end
          else
            _frag = self.where(name: key_name).first
            _frag and _frag.set_for_object obj
          end
        end
        def self.set_for_objects(key_name, _class)
          if key_name.is_a?(Array)
            return key_name.map do |k|
              set_for_objects(k, obj)
            end
          else
            _frag = self.where(name: key_name).first
            _frag and _frag.set_for_objects _class
          end
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
              unless obj.cache_keys.include?(self.name)
                obj.set(cache_keys_str: (obj.cache_keys << self.name).uniq.join("\n"))
                obj.reload
              end
            end
          end
        end
        def set_for_objects(_class)
          _class.all.map { |obj|
            unless obj.cache_keys.include?(self.name)
              obj.set(cache_keys_str: (obj.cache_keys << self.name).uniq.join("\n"))
              obj.reload
            end
          }
        end

        def self.set_for_setting(key_name, setting_obj)
          if key_name.is_a?(Array)
            return key_name.map do |k|
              set_for_setting(k, setting_obj)
            end
          else
            _frag = self.where(name: key_name).first
            _frag and _frag.set_for_setting setting_obj
          end
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
              unless setting_obj.cache_keys.include?(self.name)
                setting_obj.set(cache_keys_str: (setting_obj.cache_keys << self.name).uniq.join("\n"))
                setting_obj.reload
              end
            end
          end
        end

      end

    end
  end
end
