class RemoveVotesFromComments < ActiveRecord::Migration
  def change
    remove_column :comments, :votes, :integer, default: 0, null: false
  end
end
