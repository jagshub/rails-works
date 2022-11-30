class AddPhoneNumberToUpcomingPageSubscribers < ActiveRecord::Migration
  def change
    add_column :upcoming_page_subscribers, :phone_number, :string, null: true
  end
end
