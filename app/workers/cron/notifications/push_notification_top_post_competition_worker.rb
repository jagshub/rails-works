# frozen_string_literal: true

class Cron::Notifications::PushNotificationTopPostCompetitionWorker < ApplicationJob
  queue_as :notifications

  def perform
    Notifications::TopPostCompetitionPush.call
  end
end
