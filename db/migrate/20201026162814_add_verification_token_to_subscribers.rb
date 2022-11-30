class AddVerificationTokenToSubscribers < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    add_column :notifications_subscribers, :verification_token, :string, null: true
    add_column :notifications_subscribers, :verification_token_generated_at, :datetime, null: true

    add_index :notifications_subscribers, :verification_token, algorithm: :concurrently, unique: true
  end
end
