class AddShipAccountIdToUpcomingPages < ActiveRecord::Migration[5.0]
  def change
    add_reference :upcoming_pages, :ship_account, foreign_key: true, index: true, null: true
  end
end
