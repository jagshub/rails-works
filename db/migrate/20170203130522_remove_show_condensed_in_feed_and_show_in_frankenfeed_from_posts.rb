class RemoveShowCondensedInFeedAndShowInFrankenfeedFromPosts < ActiveRecord::Migration
  def change
    remove_column :posts, :show_condensed_in_feed
    remove_column :posts, :show_in_frankenfeed
  end
end
