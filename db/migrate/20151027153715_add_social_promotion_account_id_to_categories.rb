class AddSocialPromotionAccountIdToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :social_promotion_account_id, :string
  end
end
