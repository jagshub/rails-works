class AddSignupDesignToShipLead < ActiveRecord::Migration[5.0]
  def change
    add_column :ship_leads, :signup_design, :string
  end
end
