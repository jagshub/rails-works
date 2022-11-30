class CreateTeamUpcomingPagesAssociations < ActiveRecord::Migration[5.0]
  def change
    create_table :team_upcoming_page_associations do |t|
      t.integer :team_id, null: false
      t.integer :upcoming_page_id, null: false
      t.timestamps null: false
    end

    add_foreign_key :team_upcoming_page_associations, :teams
    add_foreign_key :team_upcoming_page_associations, :upcoming_pages

    add_index :team_upcoming_page_associations, :team_id
    add_index :team_upcoming_page_associations, [:team_id, :upcoming_page_id], unique: true, name: 'index_team_upcoming_page_associations_on_team_and_upcoming_page'
  end
end
