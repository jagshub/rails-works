class AddShowCondensedInFeedToPost < ActiveRecord::Migration
  def change
    add_column :posts, :show_condensed_in_feed, :boolean, default: false, null: false
  end
end
