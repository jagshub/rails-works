class AddStripeIndexToJob < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index(
      :jobs,
      :stripe_billing_email,
      where: 'stripe_subscription_id IS NOT NULL AND cancelled_at IS NULL',
      algorithm: :concurrently,
    )
  end
end
