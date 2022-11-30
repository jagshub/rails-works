class AddKnownAppToOAuthApplications < ActiveRecord::Migration
  def change
    add_column :oauth_applications, :known_app, :string
  end
end
