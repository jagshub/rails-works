class AddPaymentPlanToPaymentSubscriptions < ActiveRecord::Migration[5.0]
  def change
    change_table :payment_subscriptions do |t|
      t.belongs_to :plan, null: false, index: true
    end

    add_foreign_key :payment_subscriptions, :payment_plans, column: :plan_id
  end
end
