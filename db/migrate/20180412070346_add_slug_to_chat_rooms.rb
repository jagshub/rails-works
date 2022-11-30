class AddSlugToChatRooms < ActiveRecord::Migration[5.0]
  def change
    add_column :chat_rooms, :slug, :string, null: false
    add_index :chat_rooms, :slug, unique: true
  end
end
