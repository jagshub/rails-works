class AddOAuthApplicationsMaxRequestsPerHour < ActiveRecord::Migration
  def change
    add_column :oauth_applications, :max_requests_per_hour, :integer, null: false, default: 36000
  end
end
