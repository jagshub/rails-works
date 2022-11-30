class CreateUpcomingPageEmailImports < ActiveRecord::Migration
  def change
    create_table :upcoming_page_email_imports do |t|
      t.integer :state, default: 0, null: false
      t.binary :payload_csv
      t.references :upcoming_page, null: false
      t.timestamps null: false
    end
  end
end
