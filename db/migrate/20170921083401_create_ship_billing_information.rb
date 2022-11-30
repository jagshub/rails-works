class CreateShipBillingInformation < ActiveRecord::Migration
  def change
    create_table :ship_billing_informations do |t|
      t.string :stripe_customer_id, null: false
      t.string :stripe_token_id, null: false

      t.string :billing_email, null: false

      t.references :user, null: false
      t.references :ship_invite_code

      t.timestamps null: false
    end

    add_foreign_key :ship_billing_informations, :users
    add_index :ship_billing_informations, :user_id, unique: true
    add_index :ship_billing_informations, :stripe_customer_id, unique: true
    add_index :ship_billing_informations, :stripe_token_id, unique: true
  end
end
