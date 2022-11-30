class AddSharedToShipAccessRequests < ActiveRecord::Migration
  def change
    add_column :ship_access_requests, :shared, :boolean, default: false, null: false
    remove_column :ship_access_requests, :shared_on_twitter
    remove_column :ship_access_requests, :shared_on_facebook
  end
end
