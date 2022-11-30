class AddVerifiedAttributesToOAuthApplications < ActiveRecord::Migration[5.1]
  def change
    add_column :oauth_applications, :verified, :boolean, null: false, default: false
    add_column :oauth_applications, :has_write_access_for_v2_api, :boolean, null: false, default: false
  end
end
