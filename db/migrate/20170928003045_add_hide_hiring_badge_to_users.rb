class AddHideHiringBadgeToUsers < ActiveRecord::Migration
  def change
    add_column :users, :hide_hiring_badge, :boolean, default: false, null: false
  end
end
