class RemoveIgnoredColumnsFromJobs < ActiveRecord::Migration[5.1]
  def change
    safety_assured {
      remove_column :jobs, :promoted, :boolean
      remove_column :jobs, :premium, :boolean
      remove_column :jobs, :standard, :boolean
    }
  end
end
