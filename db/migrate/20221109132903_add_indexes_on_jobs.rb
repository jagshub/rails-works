class AddIndexesOnJobs < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    return if Rails.env.production?

    add_index :jobs, :kind, algorithm: :concurrently, if_not_exists: true
    add_index :jobs, :email, algorithm: :concurrently, if_not_exists: true
    add_index :jobs, :user_id, algorithm: :concurrently, if_not_exists: true
    add_index :jobs, :stripe_customer_id, algorithm: :concurrently, if_not_exists: true
  end
end
