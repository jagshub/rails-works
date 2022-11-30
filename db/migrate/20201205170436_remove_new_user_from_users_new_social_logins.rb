class RemoveNewUserFromUsersNewSocialLogins < ActiveRecord::Migration[5.1]
  def change
    safety_assured {
      remove_reference :users_new_social_logins,
                       :new_user,
                       index: true,
                       null: false,
                       foreign_key: { to_table: :users }
    }

    add_column :users_new_social_logins, :auth_response, :jsonb, null: false
    add_column :users_new_social_logins, :via_application_id, :integer
  end
end
