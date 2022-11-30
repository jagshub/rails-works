class CreateGoldenKittySponsors < ActiveRecord::Migration[5.1]
  def change
    create_table :golden_kitty_sponsors do |t|
      t.string :name, null: false
      t.string :description, null: false
      t.string :url, null: false
      t.string :website, null: false
      t.string :logo_uuid, null: false
      t.string :left_image_uuid
      t.string :right_image_uuid
      t.boolean :dark_ui, null: false, default: true
      t.string :bg_color

      t.timestamps
    end
  end
end
