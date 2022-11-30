# frozen_string_literal: true

class JobsMailer < ApplicationMailer
  def digest(presenter)
    email_campaign_name "Jobs Digest (Week #{ Time.zone.now.strftime('%U') })"

    @presenter = presenter

    @unsubscribe_url = Notifications::UnsubscribeWithToken.url(kind: 'jobs_newsletter', email: presenter.email)

    mail(
      to: presenter.email,
      from: 'Jobs Digest <jobs@producthunt.com>',
      subject: '✨ New jobs in tech on Product Hunt',
      delivery_method_options: Config.job_email_delivery_options,
    )
  end

  def cancellation(job)
    email_campaign_name 'jobs_cancellation'

    @job = job

    mail(
      to: job.stripe_billing_email,
      subject: 'Your job listing cancellation',
    )
  end

  def confirmation(job)
    email_campaign_name 'jobs_confirmation'

    @job = job

    mail(
      to: job.stripe_billing_email,
      subject: 'Your job listing on Product Hunt',
    )
  end

  def renewal(job)
    email_campaign_name 'jobs_renewal'

    @job = job

    mail(
      to: job.stripe_billing_email,
      subject: 'Your job listing - Renewal',
    )
  end
end
