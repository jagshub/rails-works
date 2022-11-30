class CreateChatRoomReports < ActiveRecord::Migration[5.0]
  def change
    create_table :chat_reports do |t|
      t.text :complaint, null: true
      t.references :chat_room, null: false
      t.references :chat_participant, null: false
      t.timestamps null: false
    end
  end
end
