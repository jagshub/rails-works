class MakeNewsletterCategoryIdNullable < ActiveRecord::Migration
  def change
    change_column_null :newsletters, :category_id, true
  end
end
