class AddAvatarUploadToUsers < ActiveRecord::Migration[5.1]
  def change
    safety_assured do
      add_column :users, :avatar_uploaded_at, :datetime, null: true
    end
  end
end
