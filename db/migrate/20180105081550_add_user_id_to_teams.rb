class AddUserIdToTeams < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :user_id, :integer, null: true
    add_foreign_key :teams, :users
    add_index :teams, :user_id
  end
end
