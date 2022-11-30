class AddPriorityToGoldenKittyCategories < ActiveRecord::Migration[5.1]
  def change
    safety_assured do
      add_column :golden_kitty_categories, :priority, :integer, null: false, default: 0
    end
  end
end
