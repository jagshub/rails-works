class AddInitialRoleToShipUserMetadata < ActiveRecord::Migration[5.0]
  def change
    add_column :ship_user_metadata, :initial_role, :integer, null: true
  end
end
