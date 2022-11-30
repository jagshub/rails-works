class AddStripeCustomerIdToJobs < ActiveRecord::Migration[5.0]
  def change
    add_column :jobs, :stripe_customer_id, :string, null: true
    add_column :jobs, :stripe_billing_email, :string, null: true
    add_column :jobs, :stripe_subscription_id, :string, null: true
  end
end
