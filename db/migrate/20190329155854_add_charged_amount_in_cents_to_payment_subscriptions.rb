class AddChargedAmountInCentsToPaymentSubscriptions < ActiveRecord::Migration[5.1]
  def change
    add_column :payment_subscriptions, :charged_amount_in_cents, :integer
  end
end
