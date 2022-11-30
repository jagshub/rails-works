class MakeUpcomingPageSubscribersEmailOptional < ActiveRecord::Migration[5.0]
  def change
    change_column_null :upcoming_page_subscribers, :email, true
  end
end
