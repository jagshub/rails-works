class AddDetailsToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :remote_ok, :boolean, default: :false, null: false
    add_column :jobs, :data, :jsonb, null: false, default: '{}'
    add_column :jobs, :company_jobs_url, :string
    add_column :jobs, :company_tagline, :string
    add_column :jobs, :job_type, :string
    add_column :jobs, :external_id, :integer
    add_column :jobs, :promoted, :boolean, null: false, default: false
    add_column :jobs, :product_id, :integer
  end
end
