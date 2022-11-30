class CreateMobileDevices < ActiveRecord::Migration[6.1]
  def change
    create_table :mobile_devices do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.string :device_uuid, null: true
      t.integer :os, null: true
      t.string :os_version, null: true
      t.string :app_version, null: true
      t.string :push_notification_token, null: true
      t.boolean :is_push_notifications_enabled, default: true, null: false
      t.string :one_signal_player_id, null: true
      t.date :last_active_at, null: false
      t.date :sign_out_at, null: true
      t.jsonb :settings, null: false, default: {}

      t.index [:user_id, :device_uuid], unique: true

      t.timestamps
    end
  end
end
