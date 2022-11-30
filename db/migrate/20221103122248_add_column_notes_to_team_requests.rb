class AddColumnNotesToTeamRequests < ActiveRecord::Migration[6.1]
  def change
    add_column :team_requests, :moderation_notes, :text
  end
end
