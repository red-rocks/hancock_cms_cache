module Hancock::Cache
  module Models
    module Fragment
      extend ActiveSupport::Concern
      include Hancock::Model

      include Hancock::Cache.orm_specific('Fragment')

      included do

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

      end

    end
  end
end
