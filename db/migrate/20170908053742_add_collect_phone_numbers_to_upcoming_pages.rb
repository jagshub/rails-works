class AddCollectPhoneNumbersToUpcomingPages < ActiveRecord::Migration
  def change
    add_column :upcoming_pages, :collect_phone_numbers, :boolean, default: false, null: false
  end
end
