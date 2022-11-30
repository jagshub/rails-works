class AddCounterCachesToCollections < ActiveRecord::Migration
  def change
    add_column :collections, :votes_count, :integer, null: false, default: 0
    add_column :collections, :credible_votes_count, :integer, null: false, default: 0
    add_index :collections, :credible_votes_count
  end
end
