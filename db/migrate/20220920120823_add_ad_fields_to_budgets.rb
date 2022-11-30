class AddAdFieldsToBudgets < ActiveRecord::Migration[6.1]
  def change
    add_column :ads_budgets, :name, :string, null: true
    add_column :ads_budgets, :tagline, :string, null: true
    add_column :ads_budgets, :thumbnail_uuid, :string, null: true
    add_column :ads_budgets, :cta_text, :string, null: true
    add_column :ads_budgets, :url, :string
    safety_assured {
      add_column :ads_budgets, :url_params, :json
    }
    change_column_default :ads_budgets, :url_params, from: nil, to: {}
  end
end
