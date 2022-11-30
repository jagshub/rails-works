class CreateShipSubscriptions < ActiveRecord::Migration
  def change
    create_table :ship_subscription_requests do |t|
      t.integer :subscription_plan, null: false
      t.string :stripe_token_id, null: false
      t.string :stripe_customer_id, null: false
      t.string :billing_email, null: false
      t.references :user, null: false
      t.timestamps null: false
    end

    add_foreign_key :ship_subscription_requests, :users
    add_index :ship_subscription_requests, :user_id, unique: true
    add_index :ship_subscription_requests, :stripe_customer_id, unique: true
    add_index :ship_subscription_requests, :stripe_token_id, unique: true
  end
end
