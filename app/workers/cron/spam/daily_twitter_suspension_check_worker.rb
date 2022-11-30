# frozen_string_literal: true

class Cron::Spam::DailyTwitterSuspensionCheckWorker < ApplicationJob
  def perform
    Spam::Users::Checks::TwitterSuspension.perform_all_later active_at: Time.zone.now.to_date - 1
  end
end
