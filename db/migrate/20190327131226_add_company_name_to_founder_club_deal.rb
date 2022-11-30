class AddCompanyNameToFounderClubDeal < ActiveRecord::Migration[5.0]
  def change
    add_column :founder_club_deals, :company_name, :string
  end
end
