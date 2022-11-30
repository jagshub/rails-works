class RemoveInvitesLeftAndDismissedNewsltterHeaderAtFromUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :invites_left
    remove_column :users, :dismissed_newsletter_header_at
  end
end
