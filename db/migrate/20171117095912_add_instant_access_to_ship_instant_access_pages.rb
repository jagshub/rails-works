class AddInstantAccessToShipInstantAccessPages < ActiveRecord::Migration[5.0]
  def change
    add_column :ship_instant_access_pages, :instant_access, :boolean, default: false, null: false
  end
end
