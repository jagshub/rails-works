class AddPrivateMessageFlagToUser < ActiveRecord::Migration
  def change
    add_column :users, :can_send_private_message, :boolean, default: false
  end
end
