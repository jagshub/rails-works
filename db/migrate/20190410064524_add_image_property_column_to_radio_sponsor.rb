class AddImagePropertyColumnToRadioSponsor < ActiveRecord::Migration[5.1]
  def change
    add_column :radio_sponsors, :image_width, :integer, null: true
    add_column :radio_sponsors, :image_height, :integer, null: true
    add_column :radio_sponsors, :image_thumbnail_width, :integer, null: true
    add_column :radio_sponsors, :image_thumbnail_height, :integer, null: true
    add_column :radio_sponsors, :image_class_name, :string, null: true

    remove_column :radio_sponsors, :image_properties, :jsonb, null: false, default: {}
  end
end
