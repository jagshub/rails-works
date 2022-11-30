class RemoveLegacyBackgroundColumnsOfCollections < ActiveRecord::Migration
  def change
    remove_column :collections, :header_image_url
    remove_column :collections, :background_image
    remove_column :collections, :background_image_processing
  end
end
