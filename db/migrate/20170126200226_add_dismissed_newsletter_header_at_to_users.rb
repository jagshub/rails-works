class AddDismissedNewsletterHeaderAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :dismissed_newsletter_header_at, :datetime
  end
end
