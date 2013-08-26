User.destroy_all
AuthItem.destroy_all

# users
visitor = User.new(name: "visitor")
visitor.save!
reader = User.new(name: "reader")
reader.save!
authorA = User.new(name: "authorA")
authorA.save!
authorB = User.new(name: "authorB")
authorB.save!
editor = User.new(name: "editor")
editor.save!
admin = User.new(name: "admin")
admin.save!

oper_create_post = Erbac.create_operation "createPost", description: "create a post"
oper_read_post = Erbac.create_operation 'readPost', description: 'read a post'
oper_update_post = Erbac.create_operation 'updatePost', description: 'update a post'
oper_delete_post = Erbac.create_operation 'deletePost', description: 'delete a post'

task_update_own_post = Erbac.create_task "updateOwnPost", description: "update a post by author himself", bizrule: "self == params[:post].author"
task_update_own_post.add_child oper_update_post

role_reader = Erbac.create_role "reader"
role_reader.add_child oper_read_post

role_author = Erbac.create_role "author"
role_author.add_child role_reader
role_author.add_child oper_create_post
role_author.add_child task_update_own_post

role_editor = Erbac.create_role "editor"
role_editor.add_child role_reader
role_editor.add_child oper_update_post

role_admin = Erbac.create_role "admin"
role_admin.add_child role_editor
role_admin.add_child role_author
role_admin.add_child oper_delete_post

Erbac.assign role_reader, reader
Erbac.assign role_author, authorA
Erbac.assign role_author, authorB
Erbac.assign role_editor, editor
Erbac.assign role_admin, admin


