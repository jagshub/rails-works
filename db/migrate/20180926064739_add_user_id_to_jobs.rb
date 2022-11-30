class AddUserIdToJobs < ActiveRecord::Migration[5.0]
  def change
    add_column :jobs, :user_id, :integer, null: true
    add_foreign_key :jobs, :users
  end
end
