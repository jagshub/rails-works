class AddRedemptionUrlToDeal < ActiveRecord::Migration[5.0]
  def change
    add_column :deals, :redemption_url, :string
  end
end
