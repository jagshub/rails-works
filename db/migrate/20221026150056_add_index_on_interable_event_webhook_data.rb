class AddIndexOnInterableEventWebhookData < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    return if Rails.env.production?
    add_index :iterable_event_webhook_data, :email, algorithm: :concurrently
  end
end
