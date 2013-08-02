class ErbacCreateAuth < ActiveRecord::Migration
  def change
    create_table(:<%= options.auth_item[2] %>) do |t|
      t.string	:name, null: false
      t.integer :auth_type
      t.text	:description
      t.text	:bizrule
      t.text	:data
    end

    create_table(:<%= options.auth_item_child[1] %>, id: false) do |t|
      t.integer	:parent_id, null: false
      t.integer :child_id, null: false
    end

    create_table(:<%= options.auth_assignment[2] %>) do |t|
      t.integer	:item_id, null: false
      t.integer :user_id, null: false
      t.text	:bizrule
      t.text	:data
    end

    add_index(:<%= options.auth_item[2] %>, :name, unique: true)
    add_index(:<%= options.auth_item_child[1] %>, [:parent_id, :child_id], unique: true)
    add_index(:<%= options.auth_assignment[2] %>, [:item_id, :user_id], unique: true)
  end
end
