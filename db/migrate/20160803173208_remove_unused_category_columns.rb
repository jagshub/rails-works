class RemoveUnusedCategoryColumns < ActiveRecord::Migration
  def change
    remove_column :categories, :submission_name_placeholder
    remove_column :categories, :submission_tagline_placeholder
  end
end
