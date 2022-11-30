class AddStateIndexToUsersNewSocialLogins < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    add_index :users_new_social_logins, :state, algorithm: :concurrently
  end
end
