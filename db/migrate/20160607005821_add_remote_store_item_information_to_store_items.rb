class AddRemoteStoreItemInformationToStoreItems < ActiveRecord::Migration
  def change
    add_column :store_items, :remote_store_item_information, :jsonb, default: '{}'
  end
end
