class AddRemoteStoreItemIdToStoreItems < ActiveRecord::Migration
  def change
    add_column :store_items, :remote_store_item_id, :string
  end
end
