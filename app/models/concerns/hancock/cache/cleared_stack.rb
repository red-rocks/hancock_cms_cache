module Hancock::Cache::ClearedStack
  extend ActiveSupport::Concern

  included do
    @@cleared_stack = []
    cattr_reader :cleared_stack
    @@cleared_stack_mutex = Mutex.new
    def self.drop_cleared_stack
      @@cleared_stack_mutex.synchronize do
        @@cleared_stack = []
      end
    end
    def drop_cleared_stack
      self.class.drop_cleared_stack
    end
    def drop_cleared_stack_if_can
      self.class.drop_cleared_stack if self.first_in_cleared_stack?
    end
    drop_cleared_stack

    def self.add_to_cleared_stack(key)
      @@cleared_stack_mutex.synchronize do
        @@cleared_stack ||= []
        @@cleared_stack << key unless is_in_cleared_stack?(key)
      end
    end
    def add_to_cleared_stack
      self.class.add_to_cleared_stack(self.name) unless self.is_in_cleared_stack?
    end

    def first_in_cleared_stack?
      @@cleared_stack and @@cleared_stack.first == self.name
    end

    def is_in_cleared_stack?
      self.class.is_in_cleared_stack?(self.name)
    end
    def self.is_in_cleared_stack?(key)
      @@cleared_stack.include?(key)
    end
  end

end
