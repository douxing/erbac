require 'rails/generators/active_record'
require 'active_support/core_ext'
require 'erbac/configure'

module ActiveRecord
  module Generators
    class ErbacGenerator < ActiveRecord::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      class_option :auth_item, type: :array, aliases: "-i", 
        default: [Erbac::Configure::AUTH_ITEM, Erbac::Configure::AUTH_ITEM_CLASS, Erbac::Configure::AUTH_ITEM_TABLE]
      class_option :auth_item_child, type: :array, aliases: "-c", 
        default: [Erbac::Configure::AUTH_ITEM_CHILD, Erbac::Configure::AUTH_ITEM_CHILD_TABLE]
      class_option :auth_assignment, type: :array, aliases: "-a", 
        default: [Erbac::Configure::AUTH_ASSIGNMENT, Erbac::Configure::AUTH_ASSIGNMENT_CLASS, Erbac::Configure::AUTH_ASSIGNMENT_TABLE]

      # def self.start(args, config)
      #   puts "start"
      #   puts "args:   " + args.inspect
      #   puts "config: " + config.inspect
      #   super
      # end

      def init_erbac_options
        puts "init"
        # assert options.auth_item[0]
        options.auth_item[1] ||= options.auth_item[0].classify || Erbac::Configure::AUTH_ITEM_CLASS
        options.auth_item[2] ||= options.auth_item[0].tableize || Erbac::Configure::AUTH_ITEM_TABLE

        # assert options.auth_item_child[0]
        options.auth_item_child[1] || options.auth_item_child[0].tableize || Erbac::Configure::AUTH_ITEM_CHILD_TABLE

        # assert options.auth_assignment[0]
        options.auth_assignment[1] || options.auth_assignment[0].classify || Erbac::Configure::AUTH_ASSIGNMENT_CLASS
        options.auth_assignment[2] || options.auth_assignment[0].tableize || Erbac::Configure::AUTH_ASSIGNMENT_TABLE
      end

      # def show_parameters
      #   puts "active_record:"
      #   puts "name:    " + self.name
      #   puts "auth_item:       " + self.options[:auth_item].inspect
      #   puts "auth_item_child: " + self.options[:auth_item_child].inspect
      #   puts "auth_assignment: " + self.options[:auth_assignment].inspect
      #   puts "options:         " + options.inspect
      # end

      def generate_auth_item_model
        Rails::Generators.invoke("active_record:model", [options.auth_item[0], "--no-migration"], behavior: behavior)
        Rails::Generators.invoke("active_record:model", [options.auth_assignment[0], "--no-migration"], behavior: behavior)
      end

      def inject_auth_item_model
        if behavior == :invoke
          inject_into_class(model_path(options.auth_item[0]), options.auth_item[1], "  control_auth_item\n")
          inject_into_class(model_path(options.auth_assignment[0]), options.auth_assignment[1], "  control_auth_assignment\n")
        end
      end

      def copy_erbac_migration
        migration_template "migration.rb", "db/migrate/erbac_create_auth"
      end

      protected

      def model_path(filename)
        File.join("app", "models", "#{filename}.rb")
      end
      
    end
  end
end