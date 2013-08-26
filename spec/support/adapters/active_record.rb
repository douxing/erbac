require 'active_record'

RSpec::Matchers::OperatorMatcher.register(ActiveRecord::Relation, '=~', RSpec::Matchers::BuiltIn::MatchArray)
ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
ActiveRecord::Base.send :include, Erbac::ActiveRecordSupport

load File.dirname(__FILE__) + '/../schema.rb'

# ActiveRecord models
class User < ActiveRecord::Base
	# attr_accessible :name
  control_access

  has_many :my_posts, class_name: "Post", inverse_of: :author
  has_many :co_posts, class_name: "Post", inverse_of: :co_workers

end

class AuthItem < ActiveRecord::Base
	# attr_accessible :name, :auth_type, :description, :bizrule, :data
  control_auth_item
end

class AuthAssignment < ActiveRecord::Base
	# attr_accessible :item_id, :user_id, :bizrule, :data
  control_auth_assignment
end

class Post < ActiveRecord::Base
	# attr_accessible :header, :author_id
	belongs_to :author, class_name: "User", inverse_of: :my_posts
	belongs_to :co_workers, class_name: "User", inverse_of: :co_posts
end
