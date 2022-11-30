class CreateShipContactsAndShipContactSubscriptions < ActiveRecord::Migration[5.0]
  def change
    create_table :ship_contacts do |t|
      t.references :ship_account, null: false, foreign_key: true, index: true
      t.references :user, foreign_key: true, index: true
      t.references :clearbit_person_profile, foreign_key: true, index: true

      t.string :email, null: false
      t.boolean :email_confirmed, null: false, default: false
      t.string :token, null: false

      t.integer :origin, null: false, default: 0

      t.integer :device_type
      t.string :os
      t.string :user_agent
      t.string :ip_address

      t.datetime :unsubscribed_at, null: true
      t.datetime :trashed_at, null: true

      t.timestamps null: false
    end

    add_index :ship_contacts, %i(ship_account_id trashed_at)
    add_index :ship_contacts, %i(ship_account_id email), unique: true

    change_table :upcoming_page_subscribers do |t|
      t.references :ship_contact, null: true, foreign_key: true, index: true
    end

    change_table :ship_accounts do |t|
      t.integer :contacts_count, null: false, default: 0
      t.integer :contacts_from_subscription_count, null: false, default: 0
      t.integer :contacts_from_message_reply_count, null: false, default: 0
      t.integer :contacts_from_import_count, null: false, default: 0
    end
  end
end
