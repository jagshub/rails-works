class RemoveInstantAccessFromShipInstantAccessPage < ActiveRecord::Migration[5.0]
  def change
    remove_column :ship_instant_access_pages, :instant_access
  end
end
