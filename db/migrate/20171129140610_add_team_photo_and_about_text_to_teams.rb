class AddTeamPhotoAndAboutTextToTeams < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :team_photo_uuid, :string, null: true
    add_column :teams, :about_text, :jsonb, null: false, default: {}
  end
end
