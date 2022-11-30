class ChangeLengthOfUserImageColumn < ActiveRecord::Migration
  def change
    change_column :users, :image, :string, limit: 300
  end
end
