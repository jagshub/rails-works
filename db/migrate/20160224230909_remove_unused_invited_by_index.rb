class RemoveUnusedInvitedByIndex < ActiveRecord::Migration
  def change
    remove_index :users, :invited_by_id
  end
end
