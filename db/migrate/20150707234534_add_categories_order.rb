class AddCategoriesOrder < ActiveRecord::Migration
  def change
    add_column :categories, :order, :integer, null: false, default: 0
  end
end
