class AddItemPlaceholdersToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :submission_name_placeholder, :string, null: true
    add_column :categories, :submission_tagline_placeholder, :string, null: true
  end
end
