class AddUserIdToUpcomingPageMessages < ActiveRecord::Migration[5.0]
  def change
    add_reference :upcoming_page_messages, :user, null: true
    add_foreign_key :upcoming_page_messages, :users
  end
end
