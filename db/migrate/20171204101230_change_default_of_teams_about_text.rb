class ChangeDefaultOfTeamsAboutText < ActiveRecord::Migration[5.0]
  def change
    change_column_null :teams, :about_text, true
    change_column_default :teams, :about_text, nil
  end
end
