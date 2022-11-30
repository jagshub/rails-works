class AddAddonsCountToProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :products, :addons_count, :integer, null: false, default: 0
  end
end
