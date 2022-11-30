class AddInvitedIdToInvites < ActiveRecord::Migration
  def change
    add_column :invites, :invited_id, :integer
    add_index :invites, :invited_id
  end
end
