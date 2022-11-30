class AddVotesCountAndCredibleVotesCountToProductAssociations < ActiveRecord::Migration[6.1]
  def change
    add_column :product_associations, :votes_count, :integer, null: false, default: 0
    add_column :product_associations, :credible_votes_count, :integer, null: false, default: 0
  end
end
