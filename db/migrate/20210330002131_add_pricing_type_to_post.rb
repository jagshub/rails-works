class AddPricingTypeToPost < ActiveRecord::Migration[5.1]
  def change
    add_column :posts, :pricing_type, :string, null: true
  end
end
