class AddStatsToUpcomingPageImport < ActiveRecord::Migration[5.0]
  def change
    add_column :upcoming_page_email_imports, :failed_count, :integer, null: false, default: 0
    add_column :upcoming_page_email_imports, :imported_count, :integer, null: false, default: 0
    add_column :upcoming_page_email_imports, :duplicated_count, :integer, null: false, default: 0
  end
end
