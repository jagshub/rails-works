class AddVisibleToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :visible, :boolean, null: false, default: true
  end
end
