module Erbac
  module AuthManage
  	def self.included(base)
  		base.extend ClassMethods
  	end

  	module ClassMethods
  		AUTH_TYPES = ["operation", "task", "role"]

  		AUTH_TYPES.each do |type|
  			define_method ("create_" + type) do |name, *args|
  				options = args.extract_options!
	  			options[:name] = name
	  			options[:auth_type] = Erbac.auth_item_class.constantize.const_get("TYPE_" + type.upcase)
	  			Erbac.auth_item_class.constantize.create options
  			end

  			define_method ("get_" + type.pluralize) do |user|
  				user.send Erbac.auth_item.pluralize.to_sym
  			end
  		end

  		def check_access(*args)
        # user.check_access auth_item, options
  			args[1].check_access args.first, args.extract_options!
  		end

  		def add_item_child(parent, child)
        parent.add_child child
  		end

  		def remove_item_child(parent, child)
  			parent.remove_child child
  		end

  		def has_item_child?(parent, child)
  			parent.has_child? child
  		end

  		def assign(item, user, bizrule=nil, data=nil)
  			item.assign user, bizrule, data
  		end

  		def revoke(item, user)
  			item.revoke user
  		end

  		def is_assigned?(item, user)
  			item.is_assigned? user
  		end

  		def get_auth_assignment(item, user)
  			item.get_auth_assignment user
  		end

  		def clear_all
  			Erbac.auth_item_class.constantize.delete_all
  		end

  		def clear_auth_assignments(*args)
  			Erbac.auth_assignment_class.constantize.delete_all args
  		end

      def execute_biz_rule?(*args)
        item = args.first
        params = args.extract_options!
        unless (item.is_a? Erbac.auth_item_class.constantize or item.is_a? Erbac.auth_assignment_class.constantize)
          raise TypeError, "Argument type not supported, should pass in #{Erbac.auth_item_class} or #{Erbac.auth_assignment_class} instance as the first parameter. Got #{item.class.to_s}", caller
        end

        if (args[1].is_a? Erbac.user_class.constantize)
          args[1].execute_biz_rule? item, params
        else
          bizrule_sandbox(item.bizrule, params, item.data)
        end
      end

      def check_access?(*args)
        unless (args.first.is_a? Erbac.auth_item_class.constantize)
          raise TypeError, "Should pass in #{Erbac.auth_item_class} instance as the first parameter. Got #{args.first.to_s}", caller
        end

        if (args[1].is_a? Erbac.user_class.constantize)
          args[1].check_access? args.first, args.extract_options!
        else
          bizrule_sandbox args.first.bizrule, args.extract_options!, args.first.data
        end
      end

  		protected
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
  end
end