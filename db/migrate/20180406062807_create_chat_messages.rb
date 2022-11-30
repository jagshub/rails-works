class CreateChatMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :chat_messages do |t|
      t.jsonb :text
      t.references :chat_participant, null: false
      t.references :chat_room, null: false
      t.datetime :trashed_at, null: true
      t.timestamps null: false
    end
  end
end
