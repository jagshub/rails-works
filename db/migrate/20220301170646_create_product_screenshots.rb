class CreateProductScreenshots < ActiveRecord::Migration[6.1]
  def change
    create_table :product_screenshots do |t|
      t.references :product, null: false, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.string :image_uuid, null: false
      t.string :alt_text, null: true
      t.integer :position, default: 0, null: false

      t.timestamps null: false
    end
  end
end
