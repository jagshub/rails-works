class AddCtaTextToPromotedProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :promoted_products, :cta_text, :string, null: true
  end
end
