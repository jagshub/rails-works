class RemoveOldRoleFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :old_role, :string
  end
end
