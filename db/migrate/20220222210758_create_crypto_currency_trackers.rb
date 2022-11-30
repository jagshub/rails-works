class CreateCryptoCurrencyTrackers < ActiveRecord::Migration[6.1]
  def change
    create_table :crypto_currency_trackers do |t|
      t.integer :token_id, null: false, index: true, unique: true
      t.string :token_symbol, null: false
      t.string :token_name, null: false
      t.decimal :usd_price, precision: 12, scale: 2, null: true

      t.timestamps
    end
  end
end
