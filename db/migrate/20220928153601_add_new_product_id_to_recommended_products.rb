class AddNewProductIdToRecommendedProducts < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    # Note(AR) This migration ran on prod and half-failed, let's not rerun it
    return if Rails.env.production?

    add_column :recommended_products, :new_product_id, :bigint
    add_index :recommended_products, :new_product_id, algorithm: :concurrently
  end
end
