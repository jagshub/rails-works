class AddIncludeShareButtonsToUpcomingPages < ActiveRecord::Migration
  def change
    change_table :upcoming_pages do |t|
      t.boolean :share_buttons, default: false, null: false
    end
  end
end
