module Hancock::Cache
  module Models::Mongoid
    module Fragment
      extend ActiveSupport::Concern

      included do

        include Hancock::Cache::Snapshotable

        index({name: 1}, {unique: true, background: true})
        index({last_clear_user_id: 1, last_clear_time: 1}, {background: true})

        field :name, type: String, localize: false, default: ""
        scope :by_name, -> (_name) {
          if _name.is_a?(Array)
            where(:name.in => _name.compact.map(&:strip))
          else
            if _name.is_a?(String)
              where(name: (_name and _name.strip))
            else
              where(name: _name)
            end
          end
        }
        scope :by_name_from_view, -> (_name) {
          by_name(name_from_view(_name))
        }

        field :desc, type: String, localize: Hancock::Cache.config.localize, default: ""
        field :virtual_path, type: String, localize: false, default: ""
        field :is_html, type: Boolean, default: true

        field :is_action_cache, type: Boolean, default: false
        scope :is_action_cache, ->  {
          where(is_action_cache: true)
        }

        field :on_ram, type: Boolean, default: false
        scope :on_ram, ->  {
          where(on_ram: true)
        }
        attr_accessor :on_ram_data
        def load_data_on_ram
          if self.on_ram and !self.name.blank?
            self.on_ram_data = Rails.cache.read(self.name)
          end
        end

        field :last_clear_time, type: DateTime
        if Hancock.rails4?
          belongs_to :last_clear_user, class_name: Mongoid::Userstamp.config.user_model_name, autosave: false
        else
          belongs_to :last_clear_user, class_name: Mongoid::Userstamp.config.user_model_name, autosave: false, optional: true, required: false

          if relations.has_key?("updater") and defined?(::Mongoid::History)
            belongs_to :updater, class_name: ::Mongoid::History.modifier_class_name, optional: true, validate: false
            _validators.delete(:updater)
            _validate_callbacks.each do |callback|
              if callback.raw_filter.respond_to?(:attributes) and callback.raw_filter.attributes.include?(:updater)
                _validate_callbacks.delete(callback)
              end
            end
          end
        end

        has_and_belongs_to_many :parents, class_name: "Hancock::Cache::Fragment", inverse_of: nil
        field :parent_names, type: Array, default: []
        def set_parent_names
          self.parent_names = self.parents.distinct(:name)
        end
        def set_parent_names!
          self.set_parent_names and self.save
        end
        def update_parent_names!
          self.set_parent_names and self.class.where(id: self.id).update(parent_names: self.parent_names)
        end
        before_save do
          if self.parent_ids_changed?
            self.set_parent_names
          end
          self
        end
        def set_parent_ids
          self.parent_ids = self.class.by_name(self.parent_names).distinct(:_id) unless self.parent_names.blank?
        end
        def set_parent_ids!
          self.set_parent_ids and self.save
        end
        def update_parent_ids!
          self.set_parent_ids and self.class.where(id: self.id).update(parent_ids: self.parent_ids, parent_names: self.parent_names)
        end

        def reset_parents
          self.parent_ids = self.parents.distinct(:_id)
        end
        def reset_parents!
          self.reset_parents and self.save
        end
        def self.reset_parents!
          self.all.map(&:reset_parents!)
        end

        def all_parents
          new_parents = _parents = self.parents.to_a
          begin
            new_parents = new_parents.map(&:parents).flatten - _parents
            _parents += new_parents
          end until(new_parents.size == 0)
          _parents.uniq
        end

        def self.destroy_dependency_graph!
          self.all.map do |f|
            f.parent_names = []
            f.parent_ids = []
            f.save
          end
        end

        def name_n_desc
          "#{self.name}<hr>#{self.desc}".html_safe
        end
        def parents_str
          self.parents.map(&:name).join(", ")
        end
        def name_n_desc_n_parents
          "#{self.name}<hr>#{self.desc}<hr>#{parents_str}".html_safe
        end

        def last_clear_data
          "#{self.last_clear_time}<hr>#{self.last_clear_user}".html_safe
        end
        def snapshot_data
          "#{self.last_dump_snapshot_time}<hr>#{self.last_restore_snapshot_time}<hr>#{self.get_snapshot(false)}".html_safe
        end

        def data(prettify = true)
          _data = Rails.cache.read(self.name)
          if prettify
            if self.is_html
              "<pre>#{CGI::escapeHTML(Nokogiri::HTML.fragment(_data).to_xhtml(indent: 2))}</pre>".html_safe
            else
              _data
            end
          else
            _data
          end
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
              set_for_object(k, obj) unless k.blank?
            end
          else
            _frag = self.where(name: key_name).first
            _frag and _frag.set_for_object obj
          end
        end
        def self.set_for_objects(key_name, _class)
          if key_name.is_a?(Array)
            return key_name.map do |k|
              set_for_objects(k, _class) unless k.blank?
            end
          else
            _frag = self.where(name: key_name).first
            _frag and _frag.set_for_objects _class
          end
        end

        # def set_for_object(obj)
        #   if obj.is_a?(Hash)
        #     if obj[:model].present?
        #       if obj[:ids].present?
        #         return obj[:ids].map do |_id|
        #           set_for_object({model: obj[:model], id: _id}) unless _id.blank?
        #         end
        #       else
        #         if obj[:id].nil?
        #           return set_for_objects(obj[:model])
        #         else
        #           obj = obj[:model].where(id: obj[:id]).first
        #         end
        #       end
        #     else
        #       return false
        #     end
        #
        #   elsif obj.is_a?(Array)
        #     return obj.map do |_obj|
        #       set_for_object(_obj) unless _obj.blank?
        #     end
        #   end
        #
        #   if obj
        #     if obj.is_a?(Class)
        #       set_for_objects obj
        #     else
        #       unless obj.cache_keys.include?(self.name)
        #         obj.set(cache_keys_str: (obj.cache_keys << self.name).uniq.join("\n"))
        #         obj.reload
        #       end
        #     end
        #   end
        # end
        # def set_for_objects(_class)
        #   _class.all.map { |obj|
        #     unless obj.cache_keys.include?(self.name)
        #       obj.set(cache_keys_str: (obj.cache_keys << self.name).uniq.join("\n"))
        #       obj.reload
        #     end
        #   }
        # end

        def self.set_for_setting(key_name, setting_obj)
          if key_name.is_a?(Array)
            return key_name.map do |k|
              set_for_setting(k, setting_obj) unless k.blank?
            end
          else
            _frag = self.where(name: key_name).first
            _frag and _frag.set_for_setting setting_obj
          end
        end
        # def set_for_setting(setting_obj)
        #   if defined?(RailsAdminModelSettings)
        #     if setting_obj.is_a?(Hash)
        #       unless setting_obj[:keys].present?
        #         if setting_obj[:key].nil?
        #           return set_for_setting({ns: setting_obj[:ns], key: //})
        #         else
        #           setting_obj = RailsAdminSettings::Setting.where(ns: setting_obj[:ns], key: setting_obj[:key]).first
        #         end
        #
        #       else
        #         return setting_obj[:keys].map do |k|
        #           set_for_setting({ns: setting_obj[:ns], key: k}) unless k.blank?
        #         end
        #       end
        #
        #     elsif setting_obj.is_a?(Array)
        #       return setting_obj.map do |obj|
        #         set_for_setting(obj) unless obj.blank?
        #       end
        #     end
        #
        #     setting_obj and set_for_object(setting_obj) and setting_obj.reload
        #   end
        # end

      end

      class_methods do
        def track_history?
          false
        end
      end

    end
  end
end
