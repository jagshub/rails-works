class CreatePromotedProductCampaigns < ActiveRecord::Migration[5.1]
  def change
    safety_assured do
      create_table :promoted_product_campaigns do |t|
        t.string :name, null: false
        t.integer :impressions_cap, null: false, default: -1
        t.integer :impressions_count, null: false, default: 0

        t.timestamps
      end
      add_reference :promoted_products, :promoted_product_campaign, null: true
      add_foreign_key :promoted_products, :promoted_product_campaigns, on_delete: :nullify
    end
  end
end
