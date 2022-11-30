class AddCategoryVisibility < ActiveRecord::Migration
  class Category < ApplicationRecord
    enum visibility: {
      secret: 0,
      open: 10
    }
  end

  def change
    add_column :categories, :visibility, :integer, null: false, default: Category.visibilities[:secret]

    Category.find_by(slug: 'tech').try(:update!, visibility: :open)
  end
end
