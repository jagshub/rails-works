class CreateUsersNewSocialLogins < ActiveRecord::Migration[5.1]
  def change
    create_table :users_new_social_logins do |t|
      t.references :user, foreign_key: true, null: false
      t.references :new_user,
                   foreign_key: { to_table: :users }, null: false, index: false

      t.string :state, null: false, default: :requested
      t.string :social, null: false
      t.string :email, null: false
      t.string :token, null: false
      t.datetime :expires_at, null: false
    end

    add_index :users_new_social_logins, :new_user_id, unique: true
  end
end
