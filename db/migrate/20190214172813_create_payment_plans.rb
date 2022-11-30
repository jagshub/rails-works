class CreatePaymentPlans < ActiveRecord::Migration[5.0]
  def change
    create_table :payment_plans do |t|
      t.integer :amount_in_cents, null: false
      t.integer :period_in_months, null: false
      t.integer :project, null: false

      t.string :stripe_plan_id, null: false
      t.string :name, null: false
      t.text :description

      t.timestamps null: false
    end

    add_index :payment_plans, :project
    add_index :payment_plans, :stripe_plan_id, unique: true
  end
end
