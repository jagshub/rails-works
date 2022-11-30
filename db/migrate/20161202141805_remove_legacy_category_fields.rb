class RemoveLegacyCategoryFields < ActiveRecord::Migration
  def change
    remove_column :categories, :auto_feature_for_everyone
    remove_column :categories, :auto_feature_post_limit
    remove_column :categories, :color
    remove_column :categories, :description
    remove_column :categories, :item_name
    remove_column :categories, :order
    remove_column :categories, :social_promotion_account_id
    remove_column :categories, :upcoming_enabled
  end
end
