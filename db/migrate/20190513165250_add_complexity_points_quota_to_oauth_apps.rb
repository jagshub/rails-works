class AddComplexityPointsQuotaToOAuthApps < ActiveRecord::Migration[5.1]
  def change
    add_column :oauth_applications, :max_points_per_hour, :integer, null: false, default: 25000
    add_column :oauth_applications, :legacy, :boolean, null: false, default: false

    remove_column :oauth_applications, :has_write_access_for_v2_api, :boolean

    add_index :oauth_applications, :legacy
  end
end
