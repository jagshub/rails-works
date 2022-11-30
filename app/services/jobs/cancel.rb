# frozen_string_literal: true

module Jobs::Cancel
  extend self

  def call(job, immediate: false)
    Job.transaction do
      attributes = { cancelled_at: Time.zone.now }
      attributes[:published] = false if immediate
      job.update!(attributes)

      if job.stripe_subscription_id?
        Stripe::Subscription.retrieve(job.stripe_subscription_id).delete(at_period_end: true)
        JobsMailer.cancellation(job).deliver_later
      end
    end
  rescue Stripe::InvalidRequestError
    nil
  end

  def after_the_fact(job, cancelled_at)
    job.update!(
      published: false,
      cancelled_at: cancelled_at,
    )
  end
end
