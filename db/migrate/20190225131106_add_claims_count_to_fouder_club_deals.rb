class AddClaimsCountToFouderClubDeals < ActiveRecord::Migration[5.0]
  def change
    add_column :founder_club_deals, :claims_count, :integer, default: 0
  end
end
