class AddTeamMembersToTeams < ActiveRecord::Migration[5.0]
  def change
    create_table :team_members do |t|
      t.references :team, null: false
      t.references :user, null: false
      t.integer :role, null: false, default: 0
      t.timestamps null: false
    end

    add_index :team_members, %i(team_id user_id), unique: true

    add_foreign_key :team_members, :users
    add_foreign_key :team_members, :teams
  end
end
