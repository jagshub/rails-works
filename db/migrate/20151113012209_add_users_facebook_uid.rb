class AddUsersFacebookUid < ActiveRecord::Migration
  def change
    add_column :users, :facebook_uid, :integer, limit: 8
  end
end
