module Erbac
  module AuthManage
  	def self.included(base)
  		base.extend ClassMethods
  	end

  	module ClassMethods
  		AUTH_TYPES = ["operation", "task", "role"]

  		AUTH_TYPES.each do |type|
  			define_method ("create_" + type) do |name, options={}|
	  			options[:name] = name
	  			options[:auth_type] = Erbac.auth_item_class.constantize.const_get("TYPE_" + type.upcase)
	  			item = Erbac.auth_item_class.constantize.new options
          item.save!
          item
  			end

  			define_method ("get_" + type.pluralize) do |user|
  				user.send Erbac.auth_item.pluralize.to_sym
  			end
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

        user = (args[1].is_a? Erbac.user_class.constantize) ? args[1] : Erbac.user_class.constantize.anonymous
        user.check_access? args.first, args.extract_options!
      end

  	end
  end
end