class AddUserJobDataToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :location, :string
    add_column :users, :job_role, :string
    add_column :users, :skills, :string, array: true, default: []
    add_column :users, :job_search, :boolean, default: false
  end
end
