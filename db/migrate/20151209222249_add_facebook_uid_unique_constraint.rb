class AddFacebookUidUniqueConstraint < ActiveRecord::Migration
  def change
    add_index :users, :facebook_uid, unique: true
  end
end
