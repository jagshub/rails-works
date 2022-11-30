class CreateUsersCryptoWalletsTable < ActiveRecord::Migration[6.1]
  def change
    create_table :users_crypto_wallets do |t|
      t.references :user, index: { unique: true }, null: false
      t.string :address, index: { unique: true }, null: false
      t.string :provider, null: false

      t.timestamps
    end
  end
end
