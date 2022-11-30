class CreateNotificationsSettings < ActiveRecord::Migration
  def change
    create_table :notifications_settings do |t|
      t.references :user, index: true, unique: true
      t.boolean :send_mention_email, null: false, default: true
      t.boolean :send_mention_push, null: false, default: true
      t.boolean :send_friend_post_email, null: false, default: true
      t.boolean :send_friend_post_push, null: false, default: true

      t.timestamps
    end
  end
end
