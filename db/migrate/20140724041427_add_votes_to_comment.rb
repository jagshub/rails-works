class AddVotesToComment < ActiveRecord::Migration
  def change
    add_column :comments, :votes, :integer, default: 0
  end
end
