ActiveRecord::Schema.define do
  self.verbose = false

  create_table(:users) do |t|
    t.string :name, null: false
  end

  create_table(:auth_items) do |t|
    t.string  :name, null: false
    t.integer :auth_type
    t.text  :description
    t.text  :bizrule
    t.text  :data
  end

  create_table(:auth_item_children, id: false) do |t|
    t.integer :parent_id, null: false
    t.integer :child_id, null: false
  end

  create_table(:auth_assignments) do |t|
    t.integer :item_id, null: false
    t.integer :user_id, null: false
    t.text  :bizrule
    t.text  :data
  end

  create_table(:posts) do |t|
    t.string :header
    t.integer :author_id
  end

  create_table(:posts_users, id: false) do |t|
    t.integer :user_id, null: false
    t.integer :post_id, null: false
  end

  add_index(:auth_items, :name, unique: true)
  add_index(:auth_item_children, [:parent_id, :child_id], unique: true)
  add_index(:auth_assignments, [:item_id, :user_id], unique: true)
  add_index(:posts, :author_id)
  add_index(:posts_users, [:user_id, :post_id], unique: true)

end
