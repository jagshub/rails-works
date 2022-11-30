class AddMoreMissingIndices < ActiveRecord::Migration
  disable_ddl_transaction!

  def change
    add_index :maker_suggestions, :product_maker_id, algorithm: :concurrently
    add_index :oauth_applications, :twitter_app_name, algorithm: :concurrently
    add_index :oauth_access_grants, :application_id, algorithm: :concurrently
    add_index :meetups, :event_date, algorithm: :concurrently
    add_index :meetup_host_associations, :meetup_id, algorithm: :concurrently
  end
end
