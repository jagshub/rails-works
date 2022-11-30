class AddSucessTextToUpcomingPageSurveys < ActiveRecord::Migration[5.0]
  def change
    add_column :upcoming_page_surveys, :success_text, :jsonb
  end
end
