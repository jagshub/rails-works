class RenameInvitesToRecommendations < ActiveRecord::Migration
  def change
    drop_table :invites
    remove_column :users, :invites_left

    create_table :recommendations do |t|
      t.integer :role, default: 0, null: false
      t.string :username, null: false
      t.integer :user_id, null: false
      t.integer :recommended_id
      t.timestamps
    end
    add_index :recommendations, :user_id
    add_index :recommendations, :recommended_id
    add_index :recommendations, :username

    add_column :users, :recommendations_left, :integer, default: 0, nil: false

    remove_index :users, :referrer_id
    remove_column :users, :referrer_id

    add_column :users, :recommended_by_id, :integer, nil: true
    add_index :users, :recommended_by_id
  end
end
