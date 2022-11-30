# frozen_string_literal: true

module Jobs::Renewal
  extend self

  def call(job)
    job.update!(last_payment_at: Time.zone.now)

    begin
      subscription = Stripe::Subscription.retrieve(job.stripe_subscription_id)
      send_slack_notification(job) if Time.zone.at(subscription.current_period_end) < Time.zone.now
    rescue StandardError => e
      raise e if Rails.env.test?

      ErrorReporting.report_error(e)
    end
  end

  private

  def send_slack_notification(job)
    SlackNotify.call(
      channel: :checkout_pages_activity,
      username: 'Jobs Bot',
      icon_emoji: ':money_mouth_face:',
      attachments: {
        author_name: 'Jobs Bot',
        fallback: "Renewal from #{ job.company_name }",
        color: '#66be00',
        title: "Renewal from #{ job.company_name }",
        fields: [
          { title: 'Job Admin URL', value: Routes.admin_job_url(job) },
          { title: 'Username', value: job.user.try(:username), short: true },
          { title: 'User ID', value: job.user.try(:id), short: true },
          job.extra_packages.present? ? { title: 'Extra Packages', value: job.extra_packages.join(', '), short: true } : nil,
        ].compact,
      },
    )
  end
end
