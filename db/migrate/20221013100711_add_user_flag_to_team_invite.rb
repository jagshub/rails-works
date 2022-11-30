class AddUserFlagToTeamInvite < ActiveRecord::Migration[6.1]
  def change
    add_column :team_invites, :user_flags_count, :integer, null: false, default: 0
  end
end
