class RemoveSubscribersTable < ActiveRecord::Migration
  def change
    drop_table :subscribers
  end
end
