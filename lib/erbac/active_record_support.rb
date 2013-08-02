module Erbac
	module ActiveRecordSupport
		def self.included(base)
  		base.extend ClassMethods
  	end

  	module ClassMethods
  		def control_access
		    has_many Erbac.auth_assignment.pluralize.to_sym,
		      dependent: :delete_all,
		      class_name: Erbac.auth_assignment_class,
		      foreign_key: "user_id"

		    accepts_nested_attributes_for Erbac.auth_assignment.pluralize.to_sym, allow_destroy: true
		    attr_accessible (Erbac.auth_assignment.pluralize + "_attributes").to_sym

		  	has_many Erbac.auth_item.pluralize.to_sym, 
		      through: Erbac.auth_assignment.pluralize.to_sym,
		      source: Erbac.auth_item.pluralize.to_sym

		    def check_access?(*args)
		      unless (args.first.is_a? Erbac.auth_item_class.constantize)
		        raise TypeError, "Should pass in #{Erbac.auth_item_class} instance as the first parameter. Got #{args.first.to_s}", caller
		      end

		      options = args.extract_options!
		      check_access_recursive? args.first, options
		    end


		    def execute_biz_rule?(*args)
		      item = args.first
		      params = args.extract_options!
		      if (item.is_a? Erbac.auth_item_class.constantize or item.is_a? Erbac.auth_assignment_class.constantize)
		        bizrule_sandbox(item.bizrule, params, item.data)
		      else
		        raise TypeError, "Argument type not supported, should pass in #{Erbac.auth_item_class} or #{Erbac.auth_assignment_class} instance as the first parameter. Got #{item.class.to_s}", caller
		      end
		    end

		    protected

		    def check_access_recursive?(item, params={})
		      if bizrule_sandbox(item.bizrule, params, item.data)
		        return true if Erbac.default_roles.inlcude? item.name
		        assignment = Erbac.auth_assignment_class.constantize.where(user_id: self, item_id: item).first
		        if assignment
		          return true if bizrule_sandbox(item.bizrule, params, item.data)
		        end
		        item.parents.each do |p|
		          return true if check_access_recursive?(p, params)
		        end
		      end
		      false
		    end

		    def bizrule_sandbox(bizrule, params={}, data=nil)
		      if (bizrule.nil? or bizrule.empty?)
		        true
		      else
		        proc do
		          $SAFE = 4 # here is a military area
		          Erbac.restrict_check_mode ? (eval bizrule) == true : (eval bizrule) != false
		        end.call
		      end
		    end
		      
		  end

		  def control_auth_item
		    attr_accessible :name, :auth_type, :description, :bizrule, :data
		    validates :name, uniqueness: true

		    has_many Erbac.auth_assignment.pluralize.to_sym,
		      dependent: :delete_all,
		      class_name: Erbac.auth_assignment_class,
		      foreign_key: "item_id"

		    accepts_nested_attributes_for Erbac.auth_assignment.pluralize.to_sym, allow_destroy: true
		    attr_accessible (Erbac.auth_assignment.pluralize + "_attributes").to_sym

		    has_many Erbac.user_class.underscore.pluralize.to_sym, 
		      through: Erbac.auth_assignment.pluralize.to_sym,
		      source: Erbac.user_class.underscore.pluralize.to_sym

		    has_and_belongs_to_many :parents,
		      join_table: Erbac.auth_item_child_table,
		      class_name: Erbac.auth_item_class,
		      foreign_key: "child_id", association_foreign_key: "parent_id"

		    has_and_belongs_to_many :children,
		      join_table: Erbac.auth_item_child_table,
		      class_name: Erbac.auth_item_class,
		      foreign_key: "parent_id", association_foreign_key: "child_id"

		    const_set("TYPE_OPERATION", 0)
		    const_set("TYPE_TASK", 1)
		    const_set("TYPE_ROLE", 2)

		    

		    def add_child item
		      if self.name == child.name
		        raise AuthItemRelationError, "Cannot add #{self.name} as a child of itself.", caller
		      end

		      check_item_child_type(self, child)

		      if detect_loop(child)
		        raise AuthItemRelationError, "Cannot add #{child.name} as a child of #{self.name}. A loop has been detected.", caller 
		      end

		      self.children << child
		    end

		    def remove_child item
		      self.children.delete item
		    end

		    def has_child? item
		      self.children.include? child
		    end

		    def assign(user, bizrule=nil, data=nil)
		      assignment = Erbac.auth_assignment_class.constantize.where({item_id: self, user_id: user}).first_or_create
		      assignemnt.bizrule = bizrule
		      assignemnt.data = data
		      assignemnt
		    end

		    def revoke(user)
		      Erbac.auth_assignment_class.constantize.delete({item_id: self, user_id: user})
		    end

		    def is_assigned?(user)
		      Erbac.auth_assignment_class.constantize.where({item_id: self, user_id: user}).any?
		    end

		    def get_auth_assignment(user)
		      Erbac.auth_assignment_class.constantize.where({item_id: self, user_id: user}).first
		    end

		    protected

		    def detect_loop(child)
		      return true if (self.name == child.name)
		      child.children.each do |g|
		        return true if self.detect_loop(g)
		      end
		      false
		    end

		    def check_item_child_type(child)
		      unless (self.is_a? Erbac.auth_item_class.constantize)
		        raise TypeError, "Should pass in #{Erbac.auth_item_class} instance as the first parameter. Got #{self.to_s}", caller
		      end

		      unless (child.is_a? Erbac.auth_item_class.constantize)
		        raise TypeError, "Should pass in #{Erbac.auth_item_class} instance as the second parameter. Got #{child.to_s}", caller
		      end

		      if self.auth_type < child.auth_type
		        raise Erbac::AuthItemRelationError, "Cannot add an itme of type #{AUTH_TYPES[child.auth_type]} to an item of type #{AUTH_TYPES[self.auth_type]}.", caller
		      end
		    end

		    # should marshal the data when it comes to database
		    # make it transparent with the user
		    define_method :marshal_around_save do |*args, &block|
		      data = self.data
		      self.data = Marshal.dump data
		      block.call # it is a trick, search it!
		      self.data = data
		    end
		    around_save :marshal_around_save

		    define_method :marshal_after_find do
		    	begin # rescue marshal error and replace with nil
		      	self.data = Marshal.restore self.data
		      rescue ArgumentError
		      	self.data = nil
		      end
		    end
		    after_find :marshal_after_find

		  end

		  def control_auth_assignment
		    attr_accessible :item_id, :user_id, :bizrule, :data

		    belongs_to Erbac.user_class.underscore.pluralize.to_sym,
		      class_name: Erbac.user_class,
		      foreign_key: "user_id"

		    belongs_to Erbac.auth_item.pluralize.to_sym,
		      class_name: Erbac.auth_item_class,
		      foreign_key: "item_id"

		    protected

		    # should marshal the data when it comes to database
		    # make it transparent with the user
		    define_method :marshal_around_save do |*args, &block|
		      data = self.data
		      self.data = Marshal.dump data
		      block.call # it is a trick, search it!
		      self.data = data
		    end
		    around_save :marshal_around_save

		    define_method :marshal_after_find do
		      begin # rescue marshal error and replace with nil
		      	self.data = Marshal.restore self.data
		      rescue ArgumentError
		      	self.data = nil
		      end
		    end
		    after_find :marshal_after_find
		  end
  	end
	end
end