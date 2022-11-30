class AddRedemptionMethodToFounderClubDeals < ActiveRecord::Migration[5.0]
  def change
    add_column :founder_club_deals, :redemption_method, :integer, default: 0
  end
end
