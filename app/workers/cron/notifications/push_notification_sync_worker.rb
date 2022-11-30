# frozen_string_literal: true

class Cron::Notifications::PushNotificationSyncWorker < ApplicationJob
  queue_as :long_running

  def perform
    Notifications::PushMetricsSync.call
  end
end
