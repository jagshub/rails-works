class AddThumbnailUuidToChatRooms < ActiveRecord::Migration[5.0]
  def change
    add_column :chat_rooms, :thumbnail_uuid, :string, null: true
  end
end
