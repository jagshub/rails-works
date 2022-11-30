class MoveJobsToNewAssociationsTable < ActiveRecord::Migration
  def up
    execute 'insert into job_product_associations (product_id, job_id, created_at, updated_at) (select product_id, jobs.id as job_id, created_at, updated_at from jobs where product_id is not null)'
  end

  def down
    # noop
  end
end
