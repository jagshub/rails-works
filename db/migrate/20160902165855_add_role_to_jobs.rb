class AddRoleToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :role, :integer, default: 0, null: false
  end
end
