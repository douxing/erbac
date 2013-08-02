module Erbac
  module Configure
    attr_accessor :strict_check_mode
    attr_accessor :default_roles

  	USER_CLASS = "User"
  	attr_accessor :user_class

  	AUTH_ITEM = "auth_item"
  	AUTH_ITEM_CLASS = AUTH_ITEM.dup.classify
  	AUTH_ITEM_TABLE = AUTH_ITEM.dup.tableize
  	attr_accessor :auth_item, :auth_item_class, :auth_item_table

  	AUTH_ITEM_CHILD = "auth_item_child"
  	AUTH_ITEM_CHILD_TABLE = AUTH_ITEM_CHILD.dup.tableize
  	attr_accessor :auth_item_child, :auth_item_child_table

  	AUTH_ASSIGNMENT = "auth_assignment"
  	AUTH_ASSIGNMENT_CLASS = AUTH_ASSIGNMENT.dup.classify
  	AUTH_ASSIGNMENT_TABLE = AUTH_ASSIGNMENT.dup.tableize
  	attr_accessor :auth_assignment, :auth_assignment_class, :auth_assignment_table

    def configure
      yield self if block_given?

      self.strict_check_mode ||= true
      self.default_roles ||= []

      self.user_class ||= USER_CLASS

      self.auth_item ||= AUTH_ITEM
    	self.auth_item_class ||= self.auth_item.classify
    	self.auth_item_table ||= self.auth_item.tableize

    	self.auth_item_child ||= AUTH_ITEM_CHILD
    	self.auth_item_child_table ||= self.auth_item_child.tableize

    	self.auth_assignment ||= AUTH_ASSIGNMENT
    	self.auth_assignment_class ||= self.auth_assignment.classify
    	self.auth_assignment_table ||= self.auth_assignment.tableize
    end
  
  end
end