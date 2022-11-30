class AddCategoryFeatureAllPostLimit < ActiveRecord::Migration
  class Category < ApplicationRecord
    DEFAULT_CATEGORY_SLUG = 'tech'
  end

  def change
    add_column :categories, :auto_feature_for_everyone, :boolean, null: true, default: true
    add_column :categories, :auto_feature_post_limit, :integer

    Category.where.not(slug: Category::DEFAULT_CATEGORY_SLUG).update_all auto_feature_for_everyone: true, auto_feature_post_limit: 2
    Category.where(slug: Category::DEFAULT_CATEGORY_SLUG).update_all auto_feature_for_everyone: false, auto_feature_post_limit: 1

    change_column_null :categories, :auto_feature_for_everyone, false
  end
end
