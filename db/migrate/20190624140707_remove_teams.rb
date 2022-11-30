class RemoveTeams < ActiveRecord::Migration[5.1]
  def change
    drop_table :team_job_associations
    drop_table :team_post_associations
    drop_table :team_members
    drop_table :team_subscribers
    drop_table :team_thankful_to_user_associations
    drop_table :team_topic_associations
    drop_table :team_upcoming_page_associations
    drop_table :teams
  end
end
