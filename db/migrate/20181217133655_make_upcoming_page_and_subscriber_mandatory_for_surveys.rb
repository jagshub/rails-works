class MakeUpcomingPageAndSubscriberMandatoryForSurveys < ActiveRecord::Migration[5.0]
  def change
    change_column_null :upcoming_page_surveys, :upcoming_page_id, false
  end
end
