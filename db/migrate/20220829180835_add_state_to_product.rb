class AddStateToProduct < ActiveRecord::Migration[6.1]
  def change
    add_column :products, :state, :string
  end
end
