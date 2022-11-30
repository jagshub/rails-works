class AddMaxVotesCountToProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :products, :sort_key_max_votes, :integer, null: false, default: 0
    add_column :products, :total_votes_count, :integer, null: false, default: 0
  end
end
