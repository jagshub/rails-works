class AddPeopleCategoryToGkCategory < ActiveRecord::Migration[6.1]
  def change
    add_column :golden_kitty_categories, :people_category, :boolean, null: false, default: false
  end
end
