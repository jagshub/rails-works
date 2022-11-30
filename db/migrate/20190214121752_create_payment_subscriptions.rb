class CreatePaymentSubscriptions < ActiveRecord::Migration[5.0]
  def change
    create_table :payment_subscriptions do |t|
      t.integer :project, null: false
      t.integer :plan_amount_in_cents, null: false

      t.string :stripe_customer_id, null: false
      t.string :stripe_subscription_id, null: false
      t.string :stripe_coupon_code
      t.string :cancellation_reason

      t.datetime :user_canceled_at
      t.datetime :stripe_canceled_at
      t.datetime :expired_at

      t.timestamps null: false

      t.references :user, null: false, foreign_key: true, index: true
    end

    add_index :payment_subscriptions, :project
    add_index :payment_subscriptions, %i(stripe_customer_id stripe_subscription_id), name: 'index_payment_subscriptions_stripe_customer_id_subscription_id'
    add_index :payment_subscriptions, %i(project user_id expired_at), where: 'expired_at is null', name: 'index_payment_subscriptions_on_project_user_id_expired_at'
  end
end
