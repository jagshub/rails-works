class AddInboxSlugToUpcomingPages < ActiveRecord::Migration[5.0]
  disable_ddl_transaction!

  def change
    add_column :upcoming_pages, :inbox_slug, :string
    add_index :upcoming_pages, :inbox_slug, unique: true, algorithm: :concurrently
  end
end
