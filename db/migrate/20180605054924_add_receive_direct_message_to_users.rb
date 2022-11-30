class AddReceiveDirectMessageToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :receive_direct_messages, :boolean, default: true, null: false
  end
end
