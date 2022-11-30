class AddBodyHtmlToUpcomingPageMessages < ActiveRecord::Migration[5.0]
  def change
    add_column :upcoming_page_messages, :body_html, :text
  end
end
