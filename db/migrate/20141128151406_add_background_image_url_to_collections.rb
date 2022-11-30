class AddBackgroundImageUrlToCollections < ActiveRecord::Migration
  def change
    add_column :collections, :background_image_url, :string
  end
end
