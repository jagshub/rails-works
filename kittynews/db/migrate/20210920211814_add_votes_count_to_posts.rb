class AddVotesCountToPosts < ActiveRecord::Migration[6.1]
  def change
    add_column :posts, :votes_count, :integer
  end
end
