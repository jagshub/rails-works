class AddMuteToSubscriptions < ActiveRecord::Migration[6.1]
  def change
    add_column :subscriptions, :muted, :boolean, default: false, null: false
  end
end
