class AddVisitStreakEndingNotificationToMobile < ActiveRecord::Migration[6.1]
  def change
    add_column :mobile_devices, :send_visit_streak_ending_push, :boolean, null: false, default: true
  end
end
