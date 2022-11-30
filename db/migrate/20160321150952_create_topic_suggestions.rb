class CreateTopicSuggestions < ActiveRecord::Migration
  def change
    create_table :topic_suggestions do |t|
      t.integer :user_id, null: false
      t.integer :post_id, null: false
      t.string :name, null: false
      t.integer :state, null: false, default: 0
      t.timestamps null: false
    end

    add_foreign_key :topic_suggestions, :users
    add_foreign_key :topic_suggestions, :posts
  end
end
