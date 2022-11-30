class AddRefundFieldsToPaymentSubscriptions < ActiveRecord::Migration[5.0]
  def change
    add_column :payment_subscriptions, :stripe_refund_id, :string
    add_column :payment_subscriptions, :refund_reason, :string
    add_column :payment_subscriptions, :refunded_at, :datetime

    remove_index :payment_subscriptions, name: 'index_payment_subscriptions_on_project_user_id_expired_at'
    add_index :payment_subscriptions, %i(project user_id expired_at refunded_at), where: 'expired_at is null and refunded_at is null', name: 'index_payment_subscriptions_project_user_expired_at_refunded_at'
  end
end
