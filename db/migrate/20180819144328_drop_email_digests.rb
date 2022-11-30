class DropEmailDigests < ActiveRecord::Migration[5.0]
  def change
    drop_table :email_digest_deliveries
    drop_table :email_digest_subscriptions
    drop_table :email_digests
  end
end
