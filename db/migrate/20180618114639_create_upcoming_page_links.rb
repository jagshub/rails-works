class CreateUpcomingPageLinks < ActiveRecord::Migration[5.0]
  def change
    create_table :upcoming_page_links do |t|
      t.references :upcoming_page, null: false
      t.string :url, null: false
      t.string :kind, null: false, index: true
      t.timestamps null: false
    end
  end
end
