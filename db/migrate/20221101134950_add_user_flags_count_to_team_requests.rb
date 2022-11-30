class AddUserFlagsCountToTeamRequests < ActiveRecord::Migration[6.1]
  def change
    add_column :team_requests, :user_flags_count, :integer, default: 0
  end
end
