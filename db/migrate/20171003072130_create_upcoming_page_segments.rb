class CreateUpcomingPageSegments < ActiveRecord::Migration
  def change
    create_table :upcoming_page_segments do |t|
      t.string :name, null: false
      t.datetime :trashed_at, null: true
      t.references :upcoming_page, null: false, index: true
      t.timestamps null: false
    end

    add_foreign_key :upcoming_page_segments, :upcoming_pages
  end
end
