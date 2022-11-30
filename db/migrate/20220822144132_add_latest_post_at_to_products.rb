class AddLatestPostAtToProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :products, :latest_post_at, :datetime, null: true
  end
end
