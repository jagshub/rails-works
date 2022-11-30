class CreatePostTopicsAssociations < ActiveRecord::Migration
  def change
    create_table :post_topic_associations do |t|
      t.integer :post_id, null: false
      t.integer :topic_id, null: false
      t.integer :user_id, null: true
      t.timestamps null: false
    end

    add_foreign_key :post_topic_associations, :posts
    add_foreign_key :post_topic_associations, :topics
    add_foreign_key :post_topic_associations, :users

    add_index :post_topic_associations, [:post_id, :topic_id], unique: true
  end
end
