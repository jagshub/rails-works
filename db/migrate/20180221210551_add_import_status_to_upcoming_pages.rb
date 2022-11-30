class AddImportStatusToUpcomingPages < ActiveRecord::Migration[5.0]
  def change
    add_column :upcoming_pages, :import_status, :integer, default: 0
  end
end
