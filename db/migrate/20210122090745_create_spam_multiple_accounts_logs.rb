class CreateSpamMultipleAccountsLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :spam_multiple_accounts_logs do |t|
      t.references :previous_user, foreign_key: { to_table: :users }, null: false
      t.references :current_user, foreign_key: { to_table: :users }, null: false
      t.jsonb :request_info

      t.timestamps
    end
  end
end
