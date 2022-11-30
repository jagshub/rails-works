class MakeShipSubscriptionColumnsNullable < ActiveRecord::Migration[5.0]
  def change
    change_column_null :ship_subscriptions, :started_at, true
    change_column_null :ship_subscriptions, :stopped_at, true

    change_column_null :ship_billing_informations, :stripe_token_id, true
    change_column_null :ship_billing_informations, :billing_email, true
  end
end
