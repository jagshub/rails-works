class ChangeBrowserExtensionSettings < ActiveRecord::Migration[5.1]
  def change
    safety_assured do
      change_column :browser_extension_settings, :show_goals_and_co_working, :boolean, default: false, null: false
    end
  end
end
