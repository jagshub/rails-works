class CreateChatRooms < ActiveRecord::Migration[5.0]
  def change
    create_table :chat_rooms do |t|
      t.string :title, null: false
      t.jsonb :description

      t.integer :subject_id, null: false
      t.string :subject_type, null: false

      t.datetime :trashed_at, null: true
      t.timestamps null: false
    end
  end
end
