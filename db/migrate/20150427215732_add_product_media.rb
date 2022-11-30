class AddProductMedia < ActiveRecord::Migration
  def change
    create_table :product_media do |t|
      t.references :product, null: false, index: true
      t.references :user, null: true
      t.integer :media_type, null: false
      t.uuid :image_uuid, null: false
      t.integer :priority, null: false, default: 0
      t.integer :original_width, null: false
      t.integer :original_height, null: false
      t.text :original_url, null: true
      t.json :metadata, null: false, default: {}
      t.timestamps null: false
    end
  end
end
