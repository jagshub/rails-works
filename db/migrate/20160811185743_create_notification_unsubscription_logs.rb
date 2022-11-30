class CreateNotificationUnsubscriptionLogs < ActiveRecord::Migration
  def change
    create_table :notification_unsubscription_logs do |t|
      t.integer :subscriber_id, null: false
      t.integer :kind, null: false
      t.string :channel_name, null: false
      t.integer :notifyable_id, default: nil
      t.string :notifyable_type, default: nil
      t.integer :source, null: false

      t.timestamps null: false
    end

    # Note(Mike Coutermarsh): notifyable may be null. But if not, must be unique
    add_index(:notification_unsubscription_logs,
              [:notifyable_type, :notifyable_id, :kind, :channel_name, :subscriber_id],
              unique: true,
              name: 'notification_unsubscription_logs_unique',
              where: 'notifyable_id IS NOT NULL and notifyable_type IS NOT NULL')

    add_index(:notification_unsubscription_logs, :subscriber_id, where: 'notifyable_id IS NULL and notifyable_type IS NULL')
  end
end
