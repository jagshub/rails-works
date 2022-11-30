# frozen_string_literal: true

class Cron::Jobs::DeliverNewJobsWorker < ApplicationJob
  def perform
    scheduled_emails = 0

    Subscriber.with_email.with_job_digest_subscription.find_each do |subscriber|
      Jobs::DigestWorker.perform_later(subscriber)
      scheduled_emails += 1
    end

    scheduled_emails
  end
end
