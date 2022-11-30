class AddBackgroundImageToCollections < ActiveRecord::Migration
  def change
    add_column :collections, :background_image, :string
    add_column :collections, :background_image_processing, :boolean, null: false, default: false
  end
end
