class RemovePreLevelUpFieldsFromUpcomingPages < ActiveRecord::Migration[5.0]
  def change
    remove_column :upcoming_pages, :collect_phone_numbers
    remove_column :upcoming_page_messages, :upcoming_page_question_option_id
    remove_column :upcoming_page_subscribers, :email
    remove_column :upcoming_page_subscribers, :user_id
    remove_column :upcoming_page_subscribers, :imported
    remove_column :upcoming_page_subscribers, :device_type
    remove_column :upcoming_page_subscribers, :os
    remove_column :upcoming_page_subscribers, :user_agent
    remove_column :upcoming_page_subscribers, :ip_address
    remove_column :upcoming_page_subscribers, :clearbit_person_profile_id
  end
end
