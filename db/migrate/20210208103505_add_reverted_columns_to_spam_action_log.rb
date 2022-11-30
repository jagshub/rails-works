class AddRevertedColumnsToSpamActionLog < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    add_column :spam_action_logs, :reverted_at, :datetime, null: true
    add_reference :spam_action_logs, :reverted_by, foreign_key: {to_table: :users}, null: true, index: false
    add_index :spam_action_logs, :reverted_by_id, algorithm: :concurrently
  end
end
