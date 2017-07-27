module Hancock::Cache
  module ParentObjects
    extend ActiveSupport::Concern

    included do

      PARENT_OBJECTS = {}

      def parent_objects
        return @parent_objects  if @parent_objects
        @parent_objects ||= PARENT_OBJECTS.keys.map { |rel| self.send(rel) }.sum
      end
      def add_parent_objects(*objs)
        (objs || []).each do |o|
          if o
            PARENT_OBJECTS.each_pair { |rel, class_name|
              self.send(rel) << o if class_name == o.class.name
            }
          end
        end
        self
      end

      def clear(forced_user = nil)
        return nil if self.is_in_cleared_stack?
        if self.set_last_clear_user(forced_user)
          Rails.cache.delete(self.name)
          self.on_ram_data = nil
          self.last_clear_time = Time.new
          self.add_to_cleared_stack
          self.parents.each { |p| p.clear(forced_user) }
          self.parent_objects.each { |p| p.touch }
          self.drop_cleared_stack_if_can
          self
        end
      end
      def clear!(forced_user = nil)
        return nil if self.is_in_cleared_stack?
        if self.set_last_clear_user(forced_user)
          Rails.cache.delete(self.name)
          self.on_ram_data = nil
          self.last_clear_time = Time.new
          self.add_to_cleared_stack
          self.parents.each { |p| p.clear(forced_user) }
          self.parent_objects.each { |p| p.touch }
          self.drop_cleared_stack_if_can
          self.save
        end
      end

    end

    class_methods do

      def add_parent_object(name, opts = {})
        opts[:inverse_of] = nil
        has_and_belongs_to_many name, opts
        PARENT_OBJECTS[name.to_sym] = opts[:class_name] || name.to_s.singularize.camelize
      end
    end

  end
end
