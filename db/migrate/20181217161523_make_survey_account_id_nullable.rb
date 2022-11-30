class MakeSurveyAccountIdNullable < ActiveRecord::Migration[5.0]
  def change
    change_column_null :upcoming_page_surveys, :ship_account_id, true
  end
end
