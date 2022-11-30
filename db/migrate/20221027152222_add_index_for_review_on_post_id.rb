class AddIndexForReviewOnPostId < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    return if Rails.env.production?
    add_index :reviews, :post_id, algorithm: :concurrently
  end
end
