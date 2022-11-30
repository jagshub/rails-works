class AddActiveToPaymentPlans < ActiveRecord::Migration[5.0]
  def change
    add_column :payment_plans, :active, :boolean, default: true, null: false
    add_index :payment_plans, :active, where: 'active is true'
  end
end
