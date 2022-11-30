class ChangeImageOnUsersToText < ActiveRecord::Migration[5.1]
  def up
    safety_assured do
      change_column :users, :image, :text
    end
  end

  def down
    safety_assured do
      change_column :users, :image, :string
    end
  end
end
