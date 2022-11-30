class AddAmaEvents < ActiveRecord::Migration
  def change
    create_table :ama_events do |t|
      t.boolean :visible, null: false, default: true
      t.references :category, null: false
      t.references :post, null: true
      t.text :url, null: true
      t.uuid :thumbnail_image_uuid, null: false
      t.uuid :maker_image_uuid, null: true
      t.date :event_date, null: false
      t.text :name, null: false
      t.text :tagline, null: false
      t.timestamps null: false
    end
  end
end
