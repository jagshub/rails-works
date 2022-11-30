class AddScheduleLockToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :disabled_when_scheduled, :boolean, default: false
  end
end
