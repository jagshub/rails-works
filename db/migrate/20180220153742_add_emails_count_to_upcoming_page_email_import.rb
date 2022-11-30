class AddEmailsCountToUpcomingPageEmailImport < ActiveRecord::Migration[5.0]
  def change
    add_column :upcoming_page_email_imports, :emails_count, :integer, default: 0
  end
end
