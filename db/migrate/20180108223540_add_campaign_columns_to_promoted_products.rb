class AddCampaignColumnsToPromotedProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :promoted_products, :home_utms, :text
    add_column :promoted_products, :newsletter_utms, :text
  end
end
