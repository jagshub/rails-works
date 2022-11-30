class AddAnalyticTestToPromotedProduct < ActiveRecord::Migration[5.1]
  def up
    add_column :promoted_products, :analytics_test, :boolean
    change_column_default :promoted_products, :analytics_test, false
  end

  def down
    remove_column :promoted_products, :analytics_test
  end
end
