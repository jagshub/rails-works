# frozen_string_literal: true

class Cron::Jobs::RenewalNotificationWorker < ApplicationJob
  def perform
    Job.where(cancelled_at: nil).where.not(stripe_subscription_id: nil).find_each do |job|
      deliver_email(job)
    end
  rescue StandardError => e
    ErrorReporting.report_error(e)
    raise e if Rails.env.test?
  end

  private

  def deliver_email(job)
    return if job.renew_notice_sent_at&.today?

    subscription = Stripe::Subscription.retrieve(job.stripe_subscription_id)

    return cancel(job, subscription.canceled_at) if subscription.canceled_at.present?
    return if Time.zone.at(subscription.current_period_end).beginning_of_day != 3.days.from_now.beginning_of_day

    job.update!(
      external_created_at: Time.current,
      renew_notice_sent_at: Time.current,
    )

    JobsMailer.renewal(job).deliver_later
  rescue Stripe::InvalidRequestError => e
    cancel(job) if e.message.start_with? 'No such subscription:'

    ErrorReporting.report_error(e, extra: { job_id: job.id })
  end

  def cancel(job, canceled_at = Time.current)
    Jobs::Cancel.after_the_fact(job, canceled_at)
  end
end
