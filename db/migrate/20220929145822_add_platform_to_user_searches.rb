class AddPlatformToUserSearches < ActiveRecord::Migration[6.1]
  def change
    add_column :search_user_searches, :platform, :string, null: false, default: 'web'
  end
end
