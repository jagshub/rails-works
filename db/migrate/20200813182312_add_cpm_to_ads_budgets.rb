class AddCpmToAdsBudgets < ActiveRecord::Migration[5.1]
  def change
    safety_assured {
      add_column :ads_budgets, :unit_price, :decimal, precision: 8, scale: 2
      add_column :ads_budgets, :closes_count, :integer, default: 0, null: false
      add_column :ads_budgets, :clicks_count, :integer, default: 0, null: false
      add_column(
        :ads_budgets, :impressions_count, :integer, default: 0, null: false
      )

      add_column(
        :ads_placements, :closes_count, :integer, default: 0, null: false
      )
      add_column(
        :ads_placements, :clicks_count, :integer, default: 0, null: false
      )
      add_column(
        :ads_placements, :impressions_count, :integer, default: 0, null: false
      )
    }
  end
end
