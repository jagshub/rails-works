class AddMembersCountToTeams < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :members_count, :integer, null: false, default: 0
  end
end
