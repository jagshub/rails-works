class AddScoreToReview < ActiveRecord::Migration
  def change
    add_column :reviews, :score, :integer, null: false, default: 0
  end
end
