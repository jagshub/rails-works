class RemoveSocialUsernameFromProducts < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      remove_column :products, :twitter_username, :string
      remove_column :products, :instagram_username, :string
    end
  end
end
