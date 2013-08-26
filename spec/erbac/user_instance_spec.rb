require "spec_helper"

describe Erbac do
	before(:all) do
		@authorA = User.where(name: "authorA").first
		@authorB = User.where(name: "authorB").first
		@editor = User.where(name: "editor").first
		@admin  = User.where(name: "administrator").first

		@first_post = Post.create! header: "first post", author_id: @authorA.id
		@second_post = Post.create! header: "second post", author_id: @authorB.id

		@role_reader = AuthItem.where(name: "reader").first
		@role_author = AuthItem.where(name: "author").first
  	@role_editor = AuthItem.where(name: "editor").first
  	@role_admin = AuthItem.where(name: "admin").first

  	@task_update_own_post = AuthItem.where(name: "updateOwnPost").first

  	@oper_update_post = AuthItem.where(name: "updatePost").first
  	@oper_delete_post = AuthItem.where(name: "deletePost").first
	end

	describe User do
		subject {nil}

		it "can not do any thing" do
			AuthItem.find_each do |auth|
		  	Erbac.check_access?(auth, subject, post: @first_post).should be_false
		  end
	  end
	end

	describe User do
  	subject { User.where(name: "visitor").first } 

	  it "can not read" do
	  	subject.check_access?(@role_reader).should be_false
	  	Erbac.check_access?(@role_reader, subject).should be_false
	  end

	  it "can not edit as author" do
	  	subject.check_access?(@role_author).should be_false
	  	Erbac.check_access?(@role_author, subject).should be_false
	  end

	  it "can not edit as editor" do
	  	subject.check_access?(@role_editor).should be_false
	  	Erbac.check_access?(@role_editor, subject).should be_false
	  end

		it "can not delete" do
	  	subject.check_access?(@oper_delete_post).should be_false
	  	Erbac.check_access?(@oper_delete_post, subject).should be_false
	  end 
  end


  describe User do
  	subject { User.where(name: "reader").first } 

  	it "can read" do
	  	subject.check_access?(@role_reader).should be_true
	  	Erbac.check_access?(@role_reader, subject).should be_true
	  end

	  it "can not edit as author" do
	  	subject.check_access?(@role_author).should be_false
	  	Erbac.check_access?(@role_author, subject).should be_false
	  end

	  it "can not edit as editor" do
	  	subject.check_access?(@role_editor).should be_false
	  	Erbac.check_access?(@role_editor, subject).should be_false
	  end

		it "can not delete" do
	  	subject.check_access?(@oper_delete_post).should be_false
	  	Erbac.check_access?(@oper_delete_post, subject).should be_false
	  end 
  end

  describe User do
  	subject { User.where(name: "editor").first } 

  	it "can read" do
	  	subject.check_access?(@role_reader).should be_true
	  	Erbac.check_access?(@role_reader, subject).should be_true
	  end

	  it "can not edit as author" do
	  	subject.check_access?(@role_author).should be_false
	  	Erbac.check_access?(@role_author, subject).should be_false
	  	subject.check_access?(@task_update_own_post, post: @first_post).should be_false
	  	Erbac.check_access?(@task_update_own_post, subject, post: @first_post).should be_false
	  end

	  it "can edit as editor" do
	  	subject.check_access?(@role_editor).should be_true
	  	Erbac.check_access?(@role_editor, subject).should be_true
	  	subject.check_access?(@oper_update_post, post: @first_post).should be_true
	  	Erbac.check_access?(@oper_update_post, subject, post: @first_post).should be_true
	  end

		it "can not delete" do
	  	subject.check_access?(@oper_delete_post).should be_false
	  	Erbac.check_access?(@oper_delete_post, subject).should be_false
	  end 
  end

  describe User do
  	subject { User.where(name: "authorA").first }

  	it "can read" do
	  	subject.check_access?(@role_reader).should be_true
	  	Erbac.check_access?(@role_reader, subject).should be_true
	  end

	  it "can edit self post as task" do
	  	subject.check_access?(@task_update_own_post, post: @first_post).should be_true
	  	Erbac.check_access?(@task_update_own_post, subject, post: @first_post).should be_true
	  	subject.check_access?(@task_update_own_post, post: @second_post).should be_false
	  	Erbac.check_access?(@task_update_own_post, subject, post: @first_post).should be_true
	  end

	  it "can edit self post as update operation" do
	  	subject.check_access?(@oper_update_post, post: @first_post).should be_true
	  	Erbac.check_access?(@oper_update_post, subject, post: @first_post).should be_true
	  	subject.check_access?(@oper_update_post, post: @second_post).should be_false
	  	Erbac.check_access?(@oper_update_post, subject, post: @second_post).should be_false
	  end 

	  it "can not edit as editor" do
	  	subject.check_access?(@role_editor).should be_false
	  	Erbac.check_access?(@role_editor, subject).should be_false
	  end

		it "can not delete" do
	  	subject.check_access?(@oper_delete_post).should be_false
	  	Erbac.check_access?(@oper_delete_post, subject).should be_false
	  end 
  end

  describe User do
  	subject { User.where(name: "admin").first }

  	it "can read" do
	  	subject.check_access?(@role_reader).should be_true
	  	Erbac.check_access?(@role_reader, subject).should be_true
	  end

	  it "can edit self post as task" do
	  	subject.check_access?(@task_update_own_post, post: @first_post).should be_false
	  	Erbac.check_access?(@task_update_own_post, subject, post: @first_post).should be_false
	  	subject.check_access?(@task_update_own_post, post: @second_post).should be_false
	  	Erbac.check_access?(@task_update_own_post, subject, post: @second_post).should be_false
	  end

	  it "can edit self post as update operation" do
	  	subject.check_access?(@oper_update_post, post: @first_post).should be_true
	  	Erbac.check_access?(@oper_update_post, subject, post: @first_post).should be_true
	  	subject.check_access?(@oper_update_post, post: @second_post).should be_true
	  	Erbac.check_access?(@oper_update_post, subject, post: @second_post).should be_true
	  end 

	  it "can not edit as editor" do
	  	subject.check_access?(@role_editor).should be_true
	  	Erbac.check_access?(@role_editor, subject).should be_true
	  end

		it "can not delete" do
	  	subject.check_access?(@oper_delete_post).should be_true
	  	Erbac.check_access?(@role_editor, subject).should be_true
	  end 
  end
end
