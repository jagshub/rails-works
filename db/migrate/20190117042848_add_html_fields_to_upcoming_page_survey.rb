class AddHtmlFieldsToUpcomingPageSurvey < ActiveRecord::Migration[5.0]
  def change
    add_column :upcoming_page_surveys, :description_html, :text
    add_column :upcoming_page_surveys, :success_html, :text
    add_column :upcoming_page_surveys, :welcome_html, :text
  end
end
