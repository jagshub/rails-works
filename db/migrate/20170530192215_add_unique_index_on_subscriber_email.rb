class AddUniqueIndexOnSubscriberEmail < ActiveRecord::Migration
  disable_ddl_transaction!

  def up
    execute 'drop index index_notifications_subscribers_on_real_email'
    execute 'drop index notifications_subscribers_unique_lower_real_email_idx'

    execute 'create unique index notifications_subscribers_unique_lower_email_idx on notifications_subscribers(lower(email))'
  end

  def down
    execute 'create unique index index_notifications_subscribers_on_real_email on notifications_subscribers(email)'
    execute 'create unique index notifications_subscribers_unique_lower_real_email_idx on notifications_subscribers(lower(email))'

    execute 'DROP INDEX notifications_subscribers_unique_lower_email_idx'
  end
end
