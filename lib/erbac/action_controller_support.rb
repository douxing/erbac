module Erbac
	module ActionControllerSupport
		def self.included(base)
  		base.extend ClassMethods
  		base.helper_method :check_access
  	end

  	def check_access
  		p "checked!"
  	end

  	module ClassMethods
  	end
	end
end