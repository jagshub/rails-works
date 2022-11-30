class AddNewReviewColumns < ActiveRecord::Migration[6.1]
  def change
    add_column :reviews, :rating, :integer, null: true
    add_column :reviews, :overall_experience, :string, null: true
    add_column :reviews, :currently_using, :integer, null: true
  end
end
