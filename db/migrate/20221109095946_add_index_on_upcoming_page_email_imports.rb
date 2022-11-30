class AddIndexOnUpcomingPageEmailImports < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    return if Rails.env.production?
    add_index :upcoming_page_email_imports, :upcoming_page_id, algorithm: :concurrently, if_not_exists: true
  end
end
