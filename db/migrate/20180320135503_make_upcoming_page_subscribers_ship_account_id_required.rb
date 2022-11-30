class MakeUpcomingPageSubscribersShipAccountIdRequired < ActiveRecord::Migration[5.0]
  def change
    change_column_null :upcoming_page_subscribers, :ship_contact_id, false
  end
end
