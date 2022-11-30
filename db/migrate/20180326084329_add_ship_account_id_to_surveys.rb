class AddShipAccountIdToSurveys < ActiveRecord::Migration[5.0]
  def change
    add_reference :upcoming_page_surveys, :ship_account, foreign_key: true, index: true, null: true
  end
end
