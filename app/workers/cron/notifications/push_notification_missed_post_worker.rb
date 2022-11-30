# frozen_string_literal: true

class Cron::Notifications::PushNotificationMissedPostWorker < ApplicationJob
  queue_as :notifications

  def perform
    Notifications::MissedPostPush.call
  end
end
