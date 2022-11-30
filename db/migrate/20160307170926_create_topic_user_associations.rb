class CreateTopicUserAssociations < ActiveRecord::Migration
  def change
    create_table :topic_user_associations do |t|
      t.integer :topic_id, null: false
      t.integer :user_id, null: false

      t.timestamps null: false
    end

    add_index :topic_user_associations, [:topic_id, :user_id], unique: true
    add_index :topic_user_associations, [:user_id, :topic_id], unique: true

    add_foreign_key :topic_user_associations, :topics
    add_foreign_key :topic_user_associations, :users
  end
end
