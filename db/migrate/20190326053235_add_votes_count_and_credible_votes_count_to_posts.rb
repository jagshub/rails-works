class AddVotesCountAndCredibleVotesCountToPosts < ActiveRecord::Migration[5.0]
  disable_ddl_transaction!

  def change
    add_column :posts, :votes_count, :integer, null: false, default: 0
    add_column :posts, :credible_votes_count, :integer, null: false, default: 0

    add_index :posts, :credible_votes_count, algorithm: :concurrently
  end
end
