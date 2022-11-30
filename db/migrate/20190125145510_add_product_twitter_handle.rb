class AddProductTwitterHandle < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :twitter_handle, :string, null: true
  end
end
