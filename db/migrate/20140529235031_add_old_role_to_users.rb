class AddOldRoleToUsers < ActiveRecord::Migration
  def change
    add_column :users, :old_role, :string
    @users = User.all
    @users.each do |u|
      u.old_role = u[:role]
      u.save!
    end
  end
end
