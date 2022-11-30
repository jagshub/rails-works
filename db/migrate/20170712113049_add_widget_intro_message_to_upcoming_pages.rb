class AddWidgetIntroMessageToUpcomingPages < ActiveRecord::Migration
  def change
    add_column :upcoming_pages, :widget_intro_message, :string
  end
end
