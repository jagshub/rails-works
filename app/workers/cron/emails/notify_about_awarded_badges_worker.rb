# frozen_string_literal: true

class Cron::Emails::NotifyAboutAwardedBadgesWorker < ApplicationJob
  queue_as :long_running

  def perform
    yesterday = 1.day.ago
    notifier = Emails::Badges.new(yesterday)
    notifier.notify_daily_award_winners
    notifier.notify_weekly_award_winners if Time.current.day == Time.current.beginning_of_week.day
    notifier.notify_monthly_award_winners if Time.current.day == Time.current.beginning_of_month.day
  end
end
