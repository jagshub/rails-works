class AddUserFlagsToReview < ActiveRecord::Migration[6.1]
  def change
    add_column :reviews, :user_flags_count, :integer, null: false, default: 0
  end
end
