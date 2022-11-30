class AddAdditionalInfoToTeamRequests < ActiveRecord::Migration[6.1]
  def change
    add_column :team_requests, :additional_info, :text
  end
end
