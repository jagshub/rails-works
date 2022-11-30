class AddClearbitPersonProfileIdToUpcomingPageSubscribers < ActiveRecord::Migration[5.0]
  def change
    add_reference :upcoming_page_subscribers, :clearbit_person_profile, null: true
  end
end
