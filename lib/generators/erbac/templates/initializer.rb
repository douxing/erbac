Erbac.configure do |config|
	# For the time being, maybe in the long term, it only support ActiveRecord...

	# Uncomment the item to override the default

	# if this is set to true, bizrule should return true restrictly
	# else bizrule will pass if they don't return false
	# NB in ruby 0 != false and 1 != true
	# config.strict_check_mode = true

	# check these roles first
	# config.default_roles = []

	# models and database tables
	<%= "# " if user_class == Erbac::Configure::USER_CLASS %>config.user_class = <%= %Q("#{user_class}") %>

	<%= "# " if options.auth_item[0] == Erbac::Configure::AUTH_ITEM %>config.auth_item = <%= %Q("#{options.auth_item[0]}") %>
	<%= "# " if options.auth_item[1] == Erbac::Configure::AUTH_ITEM_CLASS %>config.auth_item_class = <%= %Q("#{options.auth_item[1]}") %>
	<%= "# " if options.auth_item[2] == Erbac::Configure::AUTH_ITEM_TABLE %>config.auth_item_table = <%= %Q("#{options.auth_item[2]}") %>

	<%= "# " if options.auth_item_child[0] == Erbac::Configure::AUTH_ITEM_CHILD %>config.auth_item_child = <%= %Q("#{options.auth_item_child[0]}") %>
	<%= "# " if options.auth_item_child[1] == Erbac::Configure::AUTH_ITEM_CHILD_TABLE %>config.auth_item_child_table = <%= %Q("#{options.auth_item_child[1]}") %>

	<%= "# " if options.auth_assignment[0] == Erbac::Configure::AUTH_ASSIGNMENT %>config.auth_assignment = <%= %Q("#{options.auth_assignment[0]}") %>
	<%= "# " if options.auth_assignment[1] == Erbac::Configure::AUTH_ASSIGNMENT_CLASS %>config.auth_assignment = <%= %Q("#{options.auth_assignment[1]}") %>
	<%= "# " if options.auth_assignment[2] == Erbac::Configure::AUTH_ASSIGNMENT_TABLE %>config.auth_assignment_table = <%= %Q("#{options.auth_assignment[2]}") %>
end