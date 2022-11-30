class AddDateToEmailDigestDeliveries < ActiveRecord::Migration
  def change
    add_column :email_digest_deliveries, :send_date, :date, null: false
    change_column_null :email_digest_deliveries, :content, true
    add_index :email_digest_deliveries, [:email_digest_id, :send_date], unique: true
  end
end
