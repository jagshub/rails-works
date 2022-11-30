class CreatePostItemsViewsLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :post_item_views_logs do |t|
      t.integer :user_id

      t.string :visitor_id, null: false

      t.integer :seen_post_ids, null: false, default: [], array: true
      t.integer :seen_posts_count, null: false, default: 0

      t.integer :browser_width, null: false, default: 0
      t.integer :browser_height, null: false, default: 0

      t.string :browser
      t.string :device
      t.string :platform
      t.string :country
      t.string :ip
      t.string :referer

      t.string :ab_test_variant

      t.timestamps
    end
  end
end
