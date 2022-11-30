class SwtichShipInviteCodeAssoc < ActiveRecord::Migration
  def up
    remove_column :ship_invite_codes, :ship_access_requests_count

    remove_foreign_key :ship_access_requests, :ship_invite_codes
    remove_column :ship_access_requests, :ship_invite_code_id

    add_column :ship_subscription_requests, :ship_invite_code_id, :integer, null: true
    add_foreign_key :ship_subscription_requests, :ship_invite_codes
  end

  def down
    add_column :ship_invite_codes, :ship_access_requests_count, :integer, default: 0, null: false

    add_column :ship_access_requests, :ship_invite_code_id, :integer, null: true
    add_foreign_key :ship_access_requests, :ship_invite_codes

    remove_foreign_key :ship_subscription_requests, :ship_invite_codes
    remove_column :ship_subscription_requests, :ship_invite_code_id
  end
end
