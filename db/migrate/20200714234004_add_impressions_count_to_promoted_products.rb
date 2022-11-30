class AddImpressionsCountToPromotedProducts < ActiveRecord::Migration[5.1]
  def change
    safety_assured do
      add_column :promoted_products, :impressions_count, :integer, default: 0
    end
  end
end
