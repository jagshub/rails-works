class MakeCategorySlugIndexUnique < ActiveRecord::Migration
  def change
    remove_index :categories, :slug
    add_index :categories, :slug, unique: true
  end
end
