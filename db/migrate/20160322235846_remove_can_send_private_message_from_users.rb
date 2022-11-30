class RemoveCanSendPrivateMessageFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :can_send_private_message, :boolean
  end
end
