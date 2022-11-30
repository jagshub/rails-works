class RemovePermissionsFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :permissions, :integer
  end
end
