class AddShipDiscountCodeIdToShipAccessRequests < ActiveRecord::Migration
  def change
    add_column :ship_access_requests, :ship_invite_code_id, :integer, null: true
    add_foreign_key :ship_access_requests, :ship_invite_codes
  end
end
