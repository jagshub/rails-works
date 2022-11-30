class AddProductIdToPosts < ActiveRecord::Migration
  def change
    add_reference :posts, :product, index: true, foreign_key: true
  end
end
