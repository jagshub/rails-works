class CreateUpcomingPageSurveys < ActiveRecord::Migration
  def change
    create_table :upcoming_page_surveys do |t|
      t.string :title, null: false
      t.jsonb :description
      t.references :upcoming_page, null: false, index: true
      t.integer :status, null: false, default: 0
      t.timestamps null: false
    end

    add_foreign_key :upcoming_page_surveys, :upcoming_pages
  end
end
