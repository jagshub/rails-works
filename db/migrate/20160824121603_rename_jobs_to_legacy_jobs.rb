class RenameJobsToLegacyJobs < ActiveRecord::Migration
  def change
    rename_table :jobs, :legacy_jobs
  end
end
