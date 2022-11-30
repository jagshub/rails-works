class FixPostVoteNullConstraints < ActiveRecord::Migration
  def change
    change_column_null :post_votes, :user_id, false
    change_column_null :post_votes, :post_id, false
    change_column_null :post_votes, :created_at, false
    change_column_null :post_votes, :updated_at, false
  end
end
