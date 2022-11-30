class AddNoticesCategoryId < ActiveRecord::Migration
  def up
    add_column :notices, :category_id, :integer

    execute "UPDATE notices SET category_id = 1"

    change_column :notices, :category_id, :integer, null: false
  end

  def down
    remove_column :notices, :category_id
  end
end
