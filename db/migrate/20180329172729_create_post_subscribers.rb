class CreatePostSubscribers < ActiveRecord::Migration[5.0]
  def change
    create_table :post_subscribers do |t|
      t.references :user, null: false
      t.references :post, null: false
      t.timestamps null: false
    end

    add_index :post_subscribers, [:user_id, :post_id], unique: true
  end
end
