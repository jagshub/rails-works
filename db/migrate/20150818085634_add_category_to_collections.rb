class AddCategoryToCollections < ActiveRecord::Migration
  def change
    add_reference :collections, :category, index: true
    add_foreign_key :collections, :categories
  end
end
