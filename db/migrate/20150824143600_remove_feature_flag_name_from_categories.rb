class RemoveFeatureFlagNameFromCategories < ActiveRecord::Migration
  def change
    remove_column :categories, :feature_flag_name
  end
end
