class MoveKnownAppsToDoorkeeperApplications < ActiveRecord::Migration
  def change
    rename_column :oauth_applications, :known_app, :twitter_app_name
    add_column :oauth_applications, :twitter_auth_allowed, :boolean, default: false
    add_column :oauth_applications, :twitter_consumer_key, :string
    add_column :oauth_applications, :twitter_consumer_secret, :string
  end
end
