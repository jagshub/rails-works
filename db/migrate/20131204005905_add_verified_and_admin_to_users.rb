class AddVerifiedAndAdminToUsers < ActiveRecord::Migration
  def change
    add_column :users, :verified, :boolean
    add_column :users, :admin, :boolean
  end
end
