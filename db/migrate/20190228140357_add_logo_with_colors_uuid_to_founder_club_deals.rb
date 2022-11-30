class AddLogoWithColorsUuidToFounderClubDeals < ActiveRecord::Migration[5.0]
  def change
    add_column :founder_club_deals, :logo_with_colors_uuid, :string
  end
end
