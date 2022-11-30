class AddFeaturedToBestOfPages < ActiveRecord::Migration
  def change
    add_column :best_of_pages, :featured, :boolean, default: false
  end
end
