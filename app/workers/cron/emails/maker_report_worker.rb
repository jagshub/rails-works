# frozen_string_literal: true

class Cron::Emails::MakerReportWorker < ApplicationJob
  queue_as :long_running

  def perform
    MakerReports::Digest.new.deliver
  end
end
