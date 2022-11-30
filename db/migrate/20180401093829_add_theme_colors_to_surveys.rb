class AddThemeColorsToSurveys < ActiveRecord::Migration[5.0]
  def change
    add_column :upcoming_page_surveys, :link_color, :string, null: true
    add_column :upcoming_page_surveys, :button_text_color, :string, null: true
  end
end
