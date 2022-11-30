class AddSurvey2Fields < ActiveRecord::Migration[5.0]
  def change
    add_column :upcoming_page_surveys, :welcome_text, :jsonb
    add_column :upcoming_page_surveys, :background_image_uuid, :string
    add_column :upcoming_page_surveys, :background_color, :string
    add_column :upcoming_page_surveys, :button_color, :string
    add_column :upcoming_page_surveys, :title_color, :string
  end
end
