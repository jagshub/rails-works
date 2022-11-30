class AddKindToCheckoutPages < ActiveRecord::Migration[5.0]
  def change
    add_column :checkout_pages, :kind, :integer, default: 0
  end
end
