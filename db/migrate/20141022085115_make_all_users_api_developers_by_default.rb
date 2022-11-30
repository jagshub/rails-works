class MakeAllUsersAPIDevelopersByDefault < ActiveRecord::Migration
  def up
    remove_column :users, :api_developer
  end

  def down
    add_column :users, :api_developer, :boolean, default: false
  end
end
