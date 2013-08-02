require 'erbac/configure'

module Erbac
  module Generators
    class ErbacGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)
      argument :user_class, type: :string, banner: "User", desc: "User class for the system, maybe User, Account or Admin etc. in  your case."

      class_option :auth_item, type: :array, 
        default: [Configure::AUTH_ITEM, Configure::AUTH_ITEM_CLASS, Configure::AUTH_ITEM_TABLE], 
        banner: "#{Configure::AUTH_ITEM} #{Configure::AUTH_ITEM_CLASS} #{Configure::AUTH_ITEM_TABLE}", 
        aliases: "-i", desc: "auth item, model and table"
      class_option :auth_item_child, type: :array, 
        default: [Configure::AUTH_ITEM_CHILD, Configure::AUTH_ITEM_CHILD_TABLE], 
        banner: "#{Configure::AUTH_ITEM_CHILD} #{Configure::AUTH_ITEM_CHILD_TABLE}", 
        aliases: "-c", desc: "auth item child and the join table"
      class_option :auth_assignment, type: :array, 
        default: [Configure::AUTH_ASSIGNMENT, Configure::AUTH_ASSIGNMENT_CLASS, Configure::AUTH_ASSIGNMENT_TABLE], 
        banner: "#{Configure::AUTH_ASSIGNMENT} #{Configure::AUTH_ASSIGNMENT_CLASS} #{Configure::AUTH_ASSIGNMENT_TABLE}", 
        aliases: "-a",  desc: "auth assignment and the join table"

      hook_for :orm
      namespace :erbac

      desc "Generates RBAC(role base access control) models and migration files according to the USER"
      # def show_parameters
      #   puts "user:    " + self.user
      #   puts "auth_item:       " + self.options[:auth_item].inspect
      #   puts "auth_item_child: " + self.options[:auth_item_child].inspect
      #   puts "auth_assignment: " + self.options[:auth_assignment].inspect
      #   puts "options:         " + options.inspect
      # end

      def init_erbac_options
        # TODO: check the validity of the name

        # assert options.auth_item[0]
        options.auth_item[1] ||= options.auth_item[0].classify || Configure::AUTH_ITEM_CLASS
        options.auth_item[2] ||= options.auth_item[0].tableize || Configure::AUTH_ITEM_TABLE

        # assert options.auth_item_child[0]
        options.auth_item_child[1] || options.auth_item_child[0].tableize || Configure::AUTH_ITEM_CHILD_TABLE

        # assert options.auth_assignment[0]
        options.auth_assignment[1] || options.auth_assignment[0].classify || Configure::AUTH_ASSIGNMENT_CLASS
        options.auth_assignment[2] || options.auth_assignment[0].tableize || Configure::AUTH_ASSIGNMENT_TABLE
      end

      def copy_initializer_file
        template "initializer.rb", "config/initializers/erbac.rb"
      end

      def inject_user_class
        invoke "erbac:user", [ self.user_class ]
      end
      
      def show_readme
        if behavior == :invoke
          readme "README"
        end
      end

    end
  end
end
