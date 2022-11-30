class AddHiddenAtToReviews < ActiveRecord::Migration[5.0]
  def change
    add_column :reviews, :hidden_at, :datetime, null: true
  end
end
