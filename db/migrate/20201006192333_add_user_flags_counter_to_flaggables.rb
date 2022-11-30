class AddUserFlagsCounterToFlaggables < ActiveRecord::Migration[5.1]
  def change
    add_column :comments, :user_flags_count, :integer
    change_column_default :comments, :user_flags_count, 0
    add_column :posts, :user_flags_count, :integer
    change_column_default :posts, :user_flags_count, 0
    add_column :product_requests, :user_flags_count, :integer
    change_column_default :product_requests, :user_flags_count, 0
    add_column :recommendations, :user_flags_count, :integer
    change_column_default :recommendations, :user_flags_count, 0
    add_column :users, :user_flags_count, :integer
    change_column_default :users, :user_flags_count, 0
  end
end
