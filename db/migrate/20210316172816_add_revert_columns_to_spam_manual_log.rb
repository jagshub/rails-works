class AddRevertColumnsToSpamManualLog < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    add_reference :spam_manual_logs, :reverted_by, foreign_key: { to_table: :users }, null: true, index: false
    add_column :spam_manual_logs, :revert_reason, :string, null: true

    add_index :spam_manual_logs, :reverted_by_id, algorithm: :concurrently
  end
end
