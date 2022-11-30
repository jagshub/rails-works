class AddEarliestPostAtToProducts < ActiveRecord::Migration[6.1]
  def change
    add_column :products, :earliest_post_at, :datetime, null: true
  end
end
