class AddCapsAndTimeframeToBudgets < ActiveRecord::Migration[6.1]
  def change
    add_column :ads_budgets, :active_start_hour, :integer, default: 0, null: false
    add_column :ads_budgets, :active_end_hour, :integer, default: 23
  end
end
