class AddSecondaryUniqueIndexToSubscriptions < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_index :subscriptions, [:state, :subject_type, :subscriber_id, :subject_id], unique: true, algorithm: :concurrently, name: :index_subscriptions_on_subject_and_subscriber_reverse
  end
end
