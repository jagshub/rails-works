class AddMaxQuantityToStoreItems < ActiveRecord::Migration
  def change
    add_column :store_items, :max_quantity, :integer, null: false, default: 1
  end
end
