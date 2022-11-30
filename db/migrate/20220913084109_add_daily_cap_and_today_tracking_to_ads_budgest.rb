class AddDailyCapAndTodayTrackingToAdsBudgest < ActiveRecord::Migration[6.1]
  def change
    add_column :ads_budgets, :daily_cap_amount, :decimal, precision: 15, scale: 2, null: false, default: 0
    add_column :ads_budgets, :today_impressions_count, :integer, default: 0, null: false
    add_column :ads_budgets, :today_cap_reached, :boolean, default: false, null: false
    add_column :ads_budgets, :today_date, :string
  end
end
