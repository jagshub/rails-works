class CreateShipAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :ship_accounts do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.references :ship_subscription, foreign_key: true, index: { unique: true }
      t.timestamps null: false
    end
  end
end
