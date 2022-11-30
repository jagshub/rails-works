class AddVotesCountToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :votes_count, :integer
  end
end
