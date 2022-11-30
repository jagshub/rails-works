class AddIndexSuggestedProductIdOnPostDrafts < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    return if Rails.env.production?

    add_index :post_drafts, :suggested_product_id, algorithm: :concurrently, if_not_exists: true
  end
end
