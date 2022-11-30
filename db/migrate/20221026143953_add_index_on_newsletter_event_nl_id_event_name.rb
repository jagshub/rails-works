class AddIndexOnNewsletterEventNlIdEventName < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    # NOTE(jag): In prod, the index will be created manually using a data migration task.
    return if Rails.env.production?
    add_index :newsletter_events, [:newsletter_id, :event_name], algorithm: :concurrently, if_not_exists: true
  end
end