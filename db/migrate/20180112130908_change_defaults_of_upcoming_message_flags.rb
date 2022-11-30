class ChangeDefaultsOfUpcomingMessageFlags < ActiveRecord::Migration[5.0]
  def change
    execute 'UPDATE upcoming_page_messages SET visibility = 0 WHERE visibility IS NULL'
    change_column_null :upcoming_page_messages, :visibility, false
  end
end
