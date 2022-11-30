class RemoveShipSubscriptionIdFromTeams < ActiveRecord::Migration[5.0]
  def change
    remove_column :teams, :ship_subscription_id
  end
end
