class AddEnabledAtToStoreItems < ActiveRecord::Migration
  def change
    add_column :store_items, :enabled_at, :datetime, index: true
  end
end
