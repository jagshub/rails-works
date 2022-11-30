class AddCreatedAtIndexToSubscriptions < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    return if Rails.env.production?

    add_index :subscriptions, %i[created_at], algorithm: :concurrently
  end
end
