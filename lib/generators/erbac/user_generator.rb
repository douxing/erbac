require 'rails/generators/migration'
require 'active_support/core_ext'

module Erbac
  module Generators
    class UserGenerator < Rails::Generators::Base
      argument :user_class, type: :string, default: "User"

      desc "Inject erbac method in the User|Account|Admin|* class."

      def inject_user_content
        inject_into_file(model_path, "  control_access\n", :after => inject_erbac_method)
      end
      
      protected

      def inject_erbac_method
        /class[ |\t]+#{user_class}\n|class[ |\t]+#{user_class}.*\n|class[ |\t]+#{user_class.demodulize}\n|class[ |\t]+#{user_class.demodulize}.*\n/
      end
      
      def model_path
        File.join("app", "models", "#{self.user_class.underscore}.rb")
      end
      
    end
  end
end
