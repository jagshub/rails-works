class DropExpectedUsersCreateInvites < ActiveRecord::Migration
  def self.up
    drop_table :expected_users

    create_table :invites do |t|
      t.integer :role, default: 0, null: false
      t.string :username, null: false
      t.integer :user_id, null: false
      t.timestamps
    end
    add_index :invites, :user_id
    add_index :invites, :username

    add_column :users, :invites_left, :integer, default: 0, nil: false
  end

  def self.down
    remove_column :users, :invites_left
    
    remove_index :invites, :user_id
    remove_index :invites, :username
    drop_table :invites

    create_table :expected_users do |t|
      t.integer :role, default: 0, nil: false
      t.string :username, nil: false
      t.timestamps
    end
  end
end
