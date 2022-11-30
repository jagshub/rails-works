class RemoveCategoryIdFromNewsletter < ActiveRecord::Migration
  def change
    remove_column :newsletters, :category_id
  end
end
