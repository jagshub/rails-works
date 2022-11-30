class RemovePhoneNumbersAndEmailConfirmationFromUpcomingPageSubscribers < ActiveRecord::Migration[5.0]
  def change
    remove_column :upcoming_page_subscribers, :email_confirmed
    remove_column :upcoming_page_subscribers, :phone_number
  end
end
