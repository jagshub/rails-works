class AddEndsAtAndCancelledAtToShipSubscriptions < ActiveRecord::Migration[5.0]
  def change
    add_column :ship_subscriptions, :ends_at, :datetime, null: true
    add_column :ship_subscriptions, :cancelled_at, :datetime, null: true
  end
end
