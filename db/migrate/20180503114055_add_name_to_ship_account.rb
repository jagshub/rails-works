class AddNameToShipAccount < ActiveRecord::Migration[5.0]
  def change
    add_column :ship_accounts, :name, :string
  end
end
