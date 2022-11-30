class AddLastActiveIpToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :last_active_ip, :string
  end
end
