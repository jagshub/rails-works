class AddItemNameToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :item_name, :text
  end
end
