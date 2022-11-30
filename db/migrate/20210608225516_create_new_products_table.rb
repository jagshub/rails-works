class CreateNewProductsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :products do |t|
      t.string :clean_url, null: true, index: { unique: true }
      t.string :website_url, null: true, index: { unique: true }
      t.string :tagline, null: true
      t.text :description, null: true
      t.string :slug, null: false
      t.string :name, null: false
      t.boolean :reviewed, null: false, default: false
      t.string :twitter_screen_name, null: true
      t.string :instagram_handle, null: true
      t.string :source, null: false

      t.integer :media_count, null: false, default: 0
      t.integer :posts_count, null: false, default: 0
      t.timestamps
    end
  end
end
