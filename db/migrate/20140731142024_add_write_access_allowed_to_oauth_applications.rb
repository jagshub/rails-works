class AddWriteAccessAllowedToOAuthApplications < ActiveRecord::Migration
  def change
    add_column :oauth_applications, :write_access_allowed, :boolean, default: false, nil: false
  end
end
