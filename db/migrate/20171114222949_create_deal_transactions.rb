class CreateDealTransactions < ActiveRecord::Migration[5.0]
  def change
    create_table :deal_transactions do |t|
      t.integer :deal_id, foreign_key: true, null: false
      t.integer :subscriber_id, foreign_key: true, null: false

      t.timestamps
    end
  end
end
