class AddAPIDeveloperToUsers < ActiveRecord::Migration
  def change
    add_column :users, :api_developer, :boolean, default: false, nil: false
  end
end
