class AddSurveyStatusToUpcomingPages < ActiveRecord::Migration
  def change
    add_column :upcoming_pages, :survey_status, :integer, default: 0, null: false
  end
end
