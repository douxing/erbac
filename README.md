# Erbac

Q: First things first, you might ask, why the name?

A: Well, it is actually a transplantation of [yiiframework][yii]'s [Role Based Access Control][yii-rbac] system.

[yii]: http://www.yiiframework.com/
[yii-rbac]: http://www.yiiframework.com/doc/guide/1.1/en/topics.auth#role-based-access-control

## How to Use
1. Installation  
	> Put it in the Gemfile:
	> ```gem 'erbac'```  
	> then run 
	> ```bundle install```.

2. Generation  
	> In your command line tools, try to input  
	> ```rails generate erbac```  
	> here is the options for the gem:
	
		Usage:
		  rails generate erbac User [options]
		
		Options:
		  -i, [--auth-item=auth_item AuthItem auth_items]                          # auth item, model and table
		                                                                           # Default: ["auth_item", "AuthItem", "auth_items"]
		  -c, [--auth-item-child=auth_item_child auth_item_children]               # auth item child and the join table
		                                                                           # Default: ["auth_item_child", "auth_item_children"]
		  -a, [--auth-assignment=auth_assignment AuthAssignment auth_assignments]  # auth assignment and the join table
		                                                                           # Default: ["auth_assignment", "AuthAssignment", "auth_assignments"]
		  -o, [--orm=NAME]                                                         # Orm to be invoked
		                                                                           # Default: active_record
		
		Generates RBAC(role base access control) models and migration files according to the USER

	Here, the 'User' is the Model from your project's 'User' model:
	> ``` rails g erbac User ```  
	> or  
	> ``` rails g erbac Account ```  
	> or  
	> ``` rails g erbac Admin ```  
	> or whatever is suitable for your system.
	
	And an example of customization with 'auth\_item':  
	> ``` rails g erbac User --i my_auth_item ```  
	> equals  
	> ``` rails g erbac User --i my_auth_item MyAuthItem my_auth_items ```  
	> 
	> ``` rails g erbac User --i my_auth_item YourAuthItem ```  
	> equals  
	> ``` rails g erbac User --i my_auth_item YourAuthItem my_auth_items ```
	> 
	> ``` rails g erbac User --i my_auth_item YourAuthItem their_auth_items ```
	
	The same holds true for option -c and -a.  
	You don't change -o option for it only support active record right now...

3. Configuration  
	A file name erbac.rb will be generated in "rails_root/config/initializer/erbac.rb", you can see many of the options commented out as default value, and there are two points worth noting:
	* strict\_check\_mode  
		* __NB: first of all, if bizrule.nil? or bizrule.empty? holds, it will pass.__
		* set to true: if bizrule evaluates to be true, it will pass, or else, won't pass. 
		* set to false: if bizrule evaluates to be false, it won't pass, or else, will pass.

	* default roles
		roles in this array will be checked first, if none of them passed, a normal check will be carried on.

4. Role/Task/Operation creation and assignment  
	Just the same as yii, but in a Object Oriented way(with the help of Erbac helper module), example will be found at spec/support/data.rb file of this project.

5. Use
	Use ``` check_access? ``` of Erbac or the 'User' model, find the sample codes from spec/user\_instance\_spec.rb file.  
	You can also use the raw execute\_biz\_rule? to find out whether it hold only for _ONLY This_ item, whilst check\_access? checks it RECURSIVELY.
	

## Inside the Erbac ##
the model we use is defined here:

		authorA = User.new(name: "authorA")
		authorB = User.new(name: "authorB")

		oper_create_post = Erbac.create_operation "createPost", description: "create a post"
		oper_read_post = Erbac.create_operation 'readPost', description: 'read a post'
		oper_update_post = Erbac.create_operation 'updatePost', description: 'update a post'
		oper_delete_post = Erbac.create_operation 'deletePost', description: 'delete a post'
		
		task_update_own_post = Erbac.create_task "updateOwnPost", description: "update a post by author himself", bizrule: "self == params[:post].author"
		task_update_own_post.add_child oper_update_post

		role_editor = Erbac.create_role "editor"
		role_editor.add_child role_reader
		role_editor.add_child oper_update_post

		Erbac.assign role_author, authorA
		Erbac.assign role_author, authorB

		first_post = Post.create! header: "first post", author_id: @authorA.id

		authorA.check_access?(oper_update_post, post: first_post)
		
		

check_access? will check the privileges RECURSIVELY, in a top down sequence:

* check the item and if it passes
	* check if this item is a default role, if so, return true
	* check assignment, if it passes, find all the parents items and do the check again, return true if any of them return true

So in the code above, erbac will check oper_update_post first, then task\_update\_own\_post, then role\_author, bingo, it is passing the check.

Now you know why an nil or empty string bizrule will cause a pass, if not, the check_access? will not work properly RECURSIVELY.

## Cautions ##

* When you define your bizrule, either do it with in an empty string, or not assign to it at all, space string will not work preperly, thus break the check link and cause an logic error.  (" ".empty? == false)
* 'bizrule's will be check in two cases: auth\_assignment and auth\_item, so you can customize your auth_assignment to micro control your access.

## TODOs ##
* It only support Active Record, in the model layer.


