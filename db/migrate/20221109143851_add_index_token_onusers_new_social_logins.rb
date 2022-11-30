class AddIndexTokenOnusersNewSocialLogins < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    return if Rails.env.production?

    add_index :users_new_social_logins, :token, algorithm: :concurrently, if_not_exists: true
  end
end
