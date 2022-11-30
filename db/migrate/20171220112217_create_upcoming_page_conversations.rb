class CreateUpcomingPageConversations < ActiveRecord::Migration[5.0]
  def change
    create_table :upcoming_page_conversations do |t|
      t.references :upcoming_page_message, null: false, foreign_key: true
      t.references :upcoming_page, null: false, foreign_key: true
      t.timestamps null: false
    end
  end
end
