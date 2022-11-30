class CreateChatParticipants < ActiveRecord::Migration[5.0]
  def change
    create_table :chat_participants do |t|
      t.integer :subject_id, null: false
      t.string :subject_type, null: false

      t.references :chat_room, null: false
      t.timestamps null: false
    end

    add_index :chat_participants, [:subject_type, :subject_id, :chat_room_id], unique: true, name: 'index_chat_participants_on_subject_and_room_id'
  end
end
