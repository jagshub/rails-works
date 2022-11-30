class AddAlternativesCountToProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :products, :alternatives_count, :integer, null: false, default: 0
  end
end
