class AddExtraPackageFlagsJsonbToJobs < ActiveRecord::Migration[5.1]
  def change
    add_column :jobs, :extra_package_flags, :jsonb
  end
end
