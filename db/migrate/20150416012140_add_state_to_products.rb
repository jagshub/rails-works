class AddStateToProducts < ActiveRecord::Migration
  def change
    add_column :products, :state, :integer, default: 0, null: false
  end
end
