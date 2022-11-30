class AddAllowedPlansToShipInstantAccessPages < ActiveRecord::Migration[5.0]
  def change
    add_column :ship_instant_access_pages, :billing_periods, :integer, default: 0
  end
end
