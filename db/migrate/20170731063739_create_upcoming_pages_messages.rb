class CreateUpcomingPagesMessages < ActiveRecord::Migration
  def change
    create_table :upcoming_page_messages do |t|
      t.string :subject, null: false
      t.jsonb :body
      t.text :body_html
      t.integer :comments_count, default: 0, null: false
      t.references :upcoming_page, null: false
      t.timestamps null: false
    end
  end
end
