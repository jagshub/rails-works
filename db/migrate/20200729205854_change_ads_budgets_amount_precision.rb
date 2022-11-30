class ChangeAdsBudgetsAmountPrecision < ActiveRecord::Migration[5.1]
  def up
    safety_assured do
      change_column :ads_budgets, :amount, :decimal, precision: 15, scale: 2
    end
  end

  def down
  end
end
