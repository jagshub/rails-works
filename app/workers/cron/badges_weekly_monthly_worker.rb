# frozen_string_literal: true

class Cron::BadgesWeeklyMonthlyWorker < ApplicationJob
  queue_as :long_running

  def perform
    Badges::GenerateWeeklyTopPostBadgesWorker.perform_later(1.day.ago.to_s) if Time.current.day == Time.current.beginning_of_week.day
    Badges::GenerateWeeklyTopPostTopicBadgesWorker.perform_later(1.day.ago.to_s) if Time.current.day == Time.current.beginning_of_week.day

    Badges::GenerateMonthlyTopPostBadgesWorker.perform_later(1.month.ago.to_s) if Time.current.day == 1
    Badges::GenerateMonthlyTopPostTopicBadgesWorker.perform_later(1.month.ago.to_s) if Time.current.day == 1
  end
end
