class CreateNotificationSubscribers < ActiveRecord::Migration
  def change
    create_table :notifications_subscribers do |t|
      t.timestamps null: false

      t.integer :user_id, null: true
      t.string :browser_push_token, null: true
      t.string :mobile_push_token, null: true
    end

    add_foreign_key :notifications_subscribers, :users
  end
end
