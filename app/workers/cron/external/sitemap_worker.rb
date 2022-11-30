# frozen_string_literal: true

class Cron::External::SitemapWorker < ApplicationJob
  include ActiveJobRetriesCount

  queue_as :long_running

  rescue_from SitemapGenerator::SitemapFinalizedError do |exception|
    if retries_count <= 10
      retry_job wait: 5.minutes
    else
      ErrorReporting.report_error(exception)
    end
  end

  def perform
    SitemapGenerator::Interpreter.run(verbose: true)
  end
end
