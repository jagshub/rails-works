class AddStateToPosts < ActiveRecord::Migration[6.1]
  def change
    add_column :posts, :product_state, :integer, null: false, default: 0
  end
end
