class AddAboutTextHtmlToTeams < ActiveRecord::Migration[5.0]
  def change
    add_column :teams, :about_text_html, :text
  end
end
