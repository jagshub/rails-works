class AddEmailToJobs < ActiveRecord::Migration[5.0]
  def change
    add_column :jobs, :email, :string, null: true
  end
end
