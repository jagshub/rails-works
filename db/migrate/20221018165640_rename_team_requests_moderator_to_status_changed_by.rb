class RenameTeamRequestsModeratorToStatusChangedBy < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      # the table is not used yet, so it's fine
      rename_column :team_requests, :moderator_id, :status_changed_by_id
    end
  end
end
