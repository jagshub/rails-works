class AddCorrectIndexToSubscriptions < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_index :subscriptions, [:subject_id, :subject_type, :state], algorithm: :concurrently
  end
end
