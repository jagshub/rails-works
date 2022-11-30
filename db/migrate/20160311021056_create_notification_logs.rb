class CreateNotificationLogs < ActiveRecord::Migration
  def change
    create_table :notification_logs do |t|
      t.timestamps null: false

      t.integer :user_id, null: false
      t.integer :kind, null: false
      t.integer :notifyable_id, null: false
      t.string :notifyable_type, null: false

      t.datetime :push_sent_at, null: true
      t.datetime :email_sent_at, null: true
      t.datetime :browser_sent_at, null: true
    end

    add_foreign_key :notification_logs, :users

    add_index :notification_logs, [:user_id, :kind, :notifyable_id, :notifyable_type], unique: true, name: 'notification_logs_unqiue'
  end
end
