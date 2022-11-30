class AddEmailConfirmedToNotificationsSubscribers < ActiveRecord::Migration
  def change
    add_column :notifications_subscribers, :email_confirmed, :boolean, default: :false

    reversible do |d|
      d.up do
        execute 'UPDATE notifications_subscribers SET email_confirmed = true WHERE real_email IS NOT NULL'
      end
      d.down do
      end
    end
  end
end
