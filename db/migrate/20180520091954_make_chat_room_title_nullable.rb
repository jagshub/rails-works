class MakeChatRoomTitleNullable < ActiveRecord::Migration[5.0]
  def change
    change_column_null :chat_rooms, :title, true
  end
end
