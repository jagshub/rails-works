# frozen_string_literal: true

class Cron::Notifications::VisitStreakReminderWorker < ApplicationJob
  queue_as :notifications

  ENDS_IN_HOURS = 8 # NOTE(jag): hours prior to the end of their streak, the notification is sent

  USER_WITH_MIN_SEVEN_DAYS_STREAK = <<~SQL
    SELECT visit_streaks.duration, users.id FROM visit_streaks
    LEFT JOIN users ON visit_streaks.user_id = users.id
    WHERE visit_streaks.ended_at IS NULL
    AND duration >= 4
    AND users.role NOT IN (3, 10, 12, 20, 50);
  SQL

  def perform
    records_array = ExecSql.call(USER_WITH_MIN_SEVEN_DAYS_STREAK)
    return if records_array.blank?

    User.where(id: records_array.map { |r| r['id'] }).find_each do |user|
      current_streak_ends_in = ::UserVisitStreak.current_streak_ends_in(user)
      next if current_streak_ends_in.blank?
      next unless current_streak_ends_in <= ENDS_IN_HOURS

      next if user.user_visit_streak_reminders.where('created_at >= ?', 8.hours.ago).exists?

      reminder = UserVisitStreaks::Reminder.create!(user_id: user.id, streak_duration: ::UserVisitStreak.visit_streak_duration(user))

      if Features.enabled?('ph_visit_streak_reminder', user)
        Notifications.notify_about(kind: :visit_streak_ending, object: reminder)
      end
    end
  end
end
