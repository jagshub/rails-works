# frozen_string_literal: true

class Cron::Emails::TopMakerWorker < ApplicationJob
  queue_as :long_running

  def perform
    Emails::TopMakers.call(Time.zone.yesterday)
  end
end
