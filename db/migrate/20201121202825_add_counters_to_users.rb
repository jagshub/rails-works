class AddCountersToUsers < ActiveRecord::Migration[5.1]
  def up
    add_column :users, :comments_count, :integer
    add_column :users, :posts_count, :integer
    add_column :users, :product_makers_count, :integer

    change_column_default :users, :comments_count, 0
    change_column_default :users, :posts_count, 0
    change_column_default :users, :product_makers_count, 0
  end

  def down
    remove_column :users, :comments_count
    remove_column :users, :posts_count
    remove_column :users, :product_makers_count
  end
end
