require 'erbac/railtie' if defined?(Rails)
require 'erbac/configure'
require 'erbac/auth_manage'
require 'erbac/errors'
require 'erbac/active_record_support'
require 'erbac/action_controller_support'

module Erbac
  include AuthManage
  include Error
  extend Configure
end
