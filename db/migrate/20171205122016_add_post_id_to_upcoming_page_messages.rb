class AddPostIdToUpcomingPageMessages < ActiveRecord::Migration[5.0]
  def change
    add_reference :upcoming_page_messages, :post, null: true
    add_foreign_key :upcoming_page_messages, :posts
  end
end
