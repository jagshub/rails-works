class MakeMessageNullableInMessageDelivery < ActiveRecord::Migration[5.0]
  def change
    change_column_null :upcoming_page_message_deliveries, :upcoming_page_message_id, true
  end
end
