class AddCategoryFeatureFlag < ActiveRecord::Migration
  def change
    add_column :categories, :feature_flag_name, :text, null: true

    execute "UPDATE categories SET feature_flag_name = 'games_category' WHERE slug = 'games'"
  end
end
