class AddSuccessHtmlToUpcomingPages < ActiveRecord::Migration[5.0]
  def change
    add_column :upcoming_pages, :success_html, :text
  end
end
