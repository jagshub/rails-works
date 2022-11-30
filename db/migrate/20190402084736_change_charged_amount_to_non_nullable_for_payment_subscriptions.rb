class ChangeChargedAmountToNonNullableForPaymentSubscriptions < ActiveRecord::Migration[5.1]
  def change
    change_column_null :payment_subscriptions, :charged_amount_in_cents, false
  end
end
