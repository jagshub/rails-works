class CreateUpcomingPageEmailReplies < ActiveRecord::Migration[5.0]
  def change
    create_table :upcoming_page_email_replies do |t|
      t.jsonb :payload
      t.timestamps null: false
    end
  end
end
