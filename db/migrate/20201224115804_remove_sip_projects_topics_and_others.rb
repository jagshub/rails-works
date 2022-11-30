class RemoveSipProjectsTopicsAndOthers < ActiveRecord::Migration[5.1]
  def change
    safety_assured do
      remove_column :collection_post_associations, :featured
      remove_column :collection_post_associations, :featured_priority
      remove_column :collection_post_associations, :description_html

      remove_column :goals, :maker_project_id
    end

    drop_table :ab_test_completion_logs
    drop_table :collaborator_associations
    drop_table :maker_projects
    drop_table :notification_group_associations
    drop_table :notification_groups
    drop_table :post_drafts
    drop_table :ship_access_requests
    drop_table :sip_poll_votes
    drop_table :sip_poll_options
    drop_table :sip_polls
    drop_table :sip_slides
    drop_table :sips
    drop_table :topic_associations
    drop_table :topic_suggestions
  end
end
