class CreateNewsletterEvents < ActiveRecord::Migration[5.0]
  def change
    create_table :newsletter_events do |t|
      t.string :event_name, null: false
      t.datetime :time, null: false
      t.integer :subscriber_id
      t.references :newsletter, foreign_key: true
      t.string :link_url
      t.string :ip
      t.string :geo
      t.string :agent

      t.timestamps
    end

    add_foreign_key :newsletter_events, :notifications_subscribers, column: :subscriber_id
  end
end
