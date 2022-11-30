class CreatePaymentPlanDiscountAssociations < ActiveRecord::Migration[5.0]
  def change
    create_table :payment_plan_discount_associations do |t|
      t.belongs_to :plan, null: true
      t.belongs_to :discount, null: true

      t.timestamps null: false
    end

    add_foreign_key :payment_plan_discount_associations, :payment_discounts, column: :discount_id
    add_foreign_key :payment_plan_discount_associations, :payment_plans, column: :plan_id
  end
end
