class AddLandingToShipTrackingIdenities < ActiveRecord::Migration[5.0]
  def change
    add_column :ship_tracking_identities, :landing_page, :string
  end
end
