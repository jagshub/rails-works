class RemoveLegacyCollectionColumns < ActiveRecord::Migration
  def change
    remove_column :collections, :background_image_url
    remove_column :collections, :kind
    remove_column :collections, :image_url
    remove_column :collections, :promoted
    remove_column :collections, :layout
  end
end
