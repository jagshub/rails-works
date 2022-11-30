class AddAccessRequestCountToShipInviteCodes < ActiveRecord::Migration
  def change
    add_column :ship_invite_codes, :ship_access_requests_count, :integer, null: false, default: 0
  end
end
