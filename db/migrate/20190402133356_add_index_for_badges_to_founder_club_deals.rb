class AddIndexForBadgesToFounderClubDeals < ActiveRecord::Migration[5.1]
  def change
    add_index :founder_club_deals, :badges, using: :gin
  end
end
