class CreateMediaModifications < ActiveRecord::Migration[5.1]
  def change
    create_table :media_modifications do |t|
      t.belongs_to :product_media, index: { unique: true }, foreign_key: true, null: false
      t.string :original_image_uuid, null: false
      t.string :modified_image_uuid, null: false
      t.boolean :modified, default: false

      t.timestamps
    end
  end
end
