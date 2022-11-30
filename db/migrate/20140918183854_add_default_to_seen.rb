class AddDefaultToSeen < ActiveRecord::Migration
  def up
    change_column :notifications, :seen, :boolean, default: false
  end

  def down
    change_column :notifications, :seen, :boolean
  end
end
