class MakeUpcomingPageAccountIdRequired < ActiveRecord::Migration[5.0]
  def change
    change_column_null :upcoming_pages, :ship_account_id, false
  end
end
