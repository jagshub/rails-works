class AddIndexOnSubcriptionsSubscriberidSubjectid < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    # NOTE(jag): In prod, the index will be created manually using a data migration task.
    return if Rails.env.production?
    add_index :subscriptions, [:subscriber_id, :subject_id], algorithm: :concurrently
  end
end
