class AddUrlToPromotedProducts < ActiveRecord::Migration[5.1]
  def change
    safety_assured do
      add_column :promoted_products, :url, :string, null: true
    end
  end
end
