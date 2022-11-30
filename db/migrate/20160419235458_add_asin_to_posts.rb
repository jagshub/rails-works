class AddAsinToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :amazon_asin, :text, null: true
  end
end
