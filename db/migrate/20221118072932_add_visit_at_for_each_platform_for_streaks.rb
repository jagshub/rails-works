class AddVisitAtForEachPlatformForStreaks < ActiveRecord::Migration[6.1]
  def change
    add_column :visit_streaks, :last_web_visit_at, :timestamp, null: true, if_not_exists: true
    add_column :visit_streaks, :last_ios_visit_at, :timestamp, null: true, if_not_exists: true
    add_column :visit_streaks, :last_android_visit_at, :timestamp, null: true, if_not_exists: true
  end
end
