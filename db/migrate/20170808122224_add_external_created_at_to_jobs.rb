class AddExternalCreatedAtToJobs < ActiveRecord::Migration
  def change
    execute 'ALTER TABLE jobs ADD COLUMN external_created_at TIMESTAMP'
    execute 'ALTER TABLE jobs ALTER COLUMN external_created_at SET DEFAULT now()'
  end
end
