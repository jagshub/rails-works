class RemoveDealsTables < ActiveRecord::Migration[5.0]
  def change
    drop_table :deal_transactions
    drop_table :deals
  end
end
