class UpdateCardsClicksReferrerUrlToNull < ActiveRecord::Migration[6.1]
  def change
    change_column_null :cards_clicks, :referrer_url, true
  end
end
