class AddIncorporatedAndRequestStripeAtlasToShipLeads < ActiveRecord::Migration[5.0]
  def change
    add_column :ship_leads, :incorporated, :boolean, default: false
    add_column :ship_leads, :request_stripe_atlas, :boolean, default: false
  end
end
