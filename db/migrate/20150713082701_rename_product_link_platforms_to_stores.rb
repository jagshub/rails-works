class RenameProductLinkPlatformsToStores < ActiveRecord::Migration
  def change
    rename_column :product_links, :platform, :store
  end
end
