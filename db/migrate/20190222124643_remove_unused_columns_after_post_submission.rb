class RemoveUnusedColumnsAfterPostSubmission < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :experiment_tags
    remove_column :products, :twitter_handle
    remove_column :posts, :screenshot_url
    remove_column :posts, :ios_featured_at
    remove_column :posts, :amazon_asin
    remove_column :posts, :featured
  end
end
