class AddFeaturedToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :featured, :boolean, null: false, default: false
  end
end
