require 'erbac'
require 'rails'

module Erbac
  class Railtie < Rails::Railtie
    initializer 'erbac.initialize' do
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.send :include, Erbac::ActiveRecordSupport
      end

      ActiveSupport.on_load(:action_controller) do
        ActionController::Base.send :include, Erbac::ActionControllerSupport
      end
    end
  end
end
