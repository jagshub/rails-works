class AddRealEmailLowerIndexToNotificationsSubscribers < ActiveRecord::Migration
  disable_ddl_transaction!

  def up
    execute 'create unique index notifications_subscribers_unique_lower_real_email_idx on notifications_subscribers(lower(real_email))'
  end

  def down
    execute 'DROP INDEX notifications_subscribers_unique_lower_real_email_idx'
  end
end
