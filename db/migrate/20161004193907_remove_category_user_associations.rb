class RemoveCategoryUserAssociations < ActiveRecord::Migration
  def change
    drop_table :category_user_associations
  end
end
