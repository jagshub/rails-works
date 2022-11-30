class RemoveTeamMembersDuplicatedIndex < ActiveRecord::Migration[6.1]
  def change
    remove_index(
      :team_members,
      name: "index_team_members_on_user_id",
      column: :user_id
    )
  end
end
