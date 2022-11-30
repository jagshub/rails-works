class AddTrialEndsAtToShipSubscriptions < ActiveRecord::Migration[5.0]
  def change
    add_column :ship_subscriptions, :trial_ends_at, :datetime, null: true
  end
end
