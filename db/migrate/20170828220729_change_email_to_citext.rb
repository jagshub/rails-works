class ChangeEmailToCitext < ActiveRecord::Migration
  def change
    enable_extension("citext")

    # Note (Mike Coutermarsh): This is the old unique LOWER index (which converts the column to text)
    remove_index :notifications_subscribers, name: 'notifications_subscribers_unique_lower_email_idx'

    change_column :notifications_subscribers, :email, :citext
  end
end
