class CreateShipSubscriptions2 < ActiveRecord::Migration
  def change
    create_table :ship_subscriptions do |t|
      t.integer :status, null: false

      t.integer :billing_plan, null: false
      t.integer :billing_period, null: false

      t.datetime :started_at, null: false
      t.datetime :stopped_at

      t.references :user, null: false

      t.timestamps null: false
    end

    add_foreign_key :ship_subscriptions, :users
  end
end
