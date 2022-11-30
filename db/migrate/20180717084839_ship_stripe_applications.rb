class ShipStripeApplications < ActiveRecord::Migration[5.0]
  def change
    create_table :ship_stripe_applications do |t|
      t.references :ship_account, null: false, foreign_key: true
      t.timestamps null: false
    end
  end
end
