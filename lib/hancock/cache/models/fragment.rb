module Hancock::Cache
  module Models
    module Fragment
      extend ActiveSupport::Concern
      include Hancock::Model

      include Hancock::Cache.orm_specific('Fragment')

      included do
        def self.rails_admin_name
          self.name.gsub("::", "~").underscore
        end

        if Hancock::Cache.config.model_settings_support
          include RailsAdminModelSettings::ModelSettingable
        end

        # def set_last_clear_user(forced_user = nil)
        #   self.last_clear_user = forced_user if forced_user
        # end
        def set_last_clear_user!(forced_user = nil)
          self.set_last_clear_user(forced_user) and self.save
        end

        def clear(forced_user = nil)
          if self.set_last_clear_user(forced_user)
            Rails.cache.delete(self.name)
            self.last_clear_time = Time.new
          end
        end
        def clear!(forced_user = nil)
          if self.set_last_clear_user(forced_user)
            Rails.cache.delete(self.name)
            self.last_clear_time = Time.new
            self.save
          end
        end

        def name_from_view=(_name)
          self.name = name_from_view(_name)
        end
        def self.name_from_view(_name)
          "views/#{_name}"
        end

        def self.create_unless_exists(_name, _desc = nil, overwrite = nil)
          if _name.is_a?(Hash)
            _name, _desc, overwrite = _name[:name], _name[:desc], _name[:overwrite]
          end

          unless _name.blank?
            unless frag = Hancock::Cache::Fragment.cutted.where(name: _name).first
              frag = Hancock::Cache::Fragment.create(name: _name, desc: _desc)
            else
              if overwrite
                frag.desc = _desc
                frag = frag.save and frag
              end
            end
            frag
          end
        end

        def self.load_from_preloaded
          Hancock::Cache.config.preloaded_fragments.map do |f_data|
            Hancock::Cache::Fragment.create_unless_exists(f_data)
          end
        end

        def self.clear_all(forced_user = nil)
          self.all.to_a.map { |c| c.clear!(forced_user) }
        end


        def get_as_hash(overwrite = nil)
          {
            name: self.name,
            desc: self.desc,
            overwrite: overwrite
          }.compact
        end
        def get_as_json(overwrite = nil)
          get_as_hash(overwrite).to_json
        end
        def self.get_as_hash(overwrite = nil)
          Hancock::Cache::Fragment.cutted.all.to_a.map { |f| f.get_as_hash(overwrite) }
        end
        def self.get_as_json(overwrite = nil)
          Hancock::Cache::Fragment.cutted.all.to_a.map { |f| f.get_as_json(overwrite) }
        end

        # worse but working
        def self.copy_preloaded_to_config_file(fname = "config/initializers/hancock_cache.rb")
          File.truncate(fname, File.size(fname) - 4)
          File.open(fname, 'a') do |file|
            file.write "  config.preloaded_fragments = [\n    #{Hancock::Cache::Fragment.get_as_json.join(",\n    ")}\n  ]\nend"
          end
        end



        def self.manager_can_add_actions
          ret = [:hancock_cache_clear, :hancock_cache_global_clear, :hancock_cache_get_snapshot]
          ret << :model_settings if Hancock::Cache.config.model_settings_support
          ret << :model_accesses if Hancock::Cache.config.user_abilities_support
          ret += [:comments, :model_comments] if Hancock::Cache.config.ra_comments_support
          ret.freeze
        end
        def self.rails_admin_add_visible_actions
          ret = [:hancock_cache_clear, :hancock_cache_global_clear, :hancock_cache_get_snapshot]
          ret << :model_settings if Hancock::Cache.config.model_settings_support
          ret << :model_accesses if Hancock::Cache.config.user_abilities_support
          ret += [:comments, :model_comments] if Hancock::Cache.config.ra_comments_support
          ret.freeze
        end

      end

    end
  end
end
