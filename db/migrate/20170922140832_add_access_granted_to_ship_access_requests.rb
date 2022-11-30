class AddAccessGrantedToShipAccessRequests < ActiveRecord::Migration
  def change
    add_column :ship_access_requests, :access_granted, :boolean, default: false
  end
end
