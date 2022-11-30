class CreateUpcomingPageSubscriberSearches < ActiveRecord::Migration[5.0]
  def change
    create_table :upcoming_page_subscriber_searches do |t|
      t.references :upcoming_page, null: false
      t.string :name, null: false
      t.jsonb :filters, null: false, default: []
      t.timestamps null: false
    end

    add_foreign_key :upcoming_page_subscriber_searches, :upcoming_pages
  end
end
