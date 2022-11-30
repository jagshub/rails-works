class AddExperimentalPackagesToJobs < ActiveRecord::Migration[5.1]
  def change
    add_column :jobs, :extra_packages, :string, array: true, null: true
  end
end
