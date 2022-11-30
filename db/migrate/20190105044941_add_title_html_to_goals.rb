class AddTitleHtmlToGoals < ActiveRecord::Migration[5.0]
  def change
    add_column :goals, :title_html, :text
  end
end
