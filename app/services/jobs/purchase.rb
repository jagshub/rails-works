# frozen_string_literal: true

class Jobs::Purchase
  CURRENCY = 'usd'

  attr_reader :billing_email, :stripe_token, :customer, :job, :plan, :subscription, :extra_packages, :request_info, :user, :feature_homepage, :feature_job_digest, :extra

  class << self
    def call(inputs:, job:, plan:, user:, request_info: {})
      new(inputs: inputs, job: job, plan: plan, user: user, request_info: request_info).call
    end
  end

  def initialize(inputs:, job:, plan:, user:, request_info: {})
    @job = job
    @plan = plan
    @billing_email = inputs[:billing_email]
    @extra = inputs[:extra]
    @stripe_token = inputs[:stripe_token_id]
    @extra_packages = inputs[:extra_packages]
    @user = user
    @request_info = request_info
    @feature_job_digest = inputs[:feature_job_digest]
    @feature_homepage = inputs[:feature_homepage]
  end

  def call
    perform_purchase

    anchor_time = Time.zone.at(subscription.billing_cycle_anchor) if subscription.billing_cycle_anchor.present?

    job.update!(
      published: true,
      stripe_customer_id: customer.id,
      stripe_billing_email: billing_email,
      stripe_subscription_id: subscription.id,
      last_payment_at: Time.zone.now,
      billing_cycle_anchor: anchor_time,
      extra_packages: extra_packages,
      feature_homepage: feature_homepage,
      feature_job_digest: feature_job_digest,
    )

    begin
      send_email_confirmation
      send_slack_notification
      send_admin_email_notification
      job
    rescue StandardError => e
      raise e if Rails.env.test?

      ErrorReporting.report_error(e)
    end
  end

  private

  def perform_purchase
    @customer = External::StripeApi.create_customer(
      email: billing_email,
      stripe_token_id: stripe_token,
      metadata: { job_id: job&.id, user_id: user&.id },
      extra: extra,
    )

    @subscription = Stripe::Subscription.create(
      customer: customer.id,
      coupon: job.discount_page&.stripe_coupon_code,
      items: [
        {
          plan: plan.sku,
        },
      ],
    )
  end

  def send_email_confirmation
    JobsMailer.confirmation(job).deliver_later
  end

  def send_admin_email_notification
    AdminMailer.job_with_extra_packages(job).deliver_later if job.extra_packages.present?
  end

  def send_slack_notification
    SlackNotify.call(
      channel: :checkout_pages_activity,
      username: 'Jobs Bot',
      icon_emoji: ':money_mouth_face:',
      attachment: {
        author_name: 'Jobs Bot',
        fallback: "New purchase from #{ billing_email }",
        color: '#66be00',
        title: "New purchase from #{ billing_email }",
        fields: [
          { title: 'Stripe SKU', value: plan.sku, short: true },
          { title: 'Billing Email', value: billing_email, short: true },
          { title: 'Username', value: job.user.try(:username), short: true },
          { title: 'User ID', value: job.user.try(:id), short: true },
          { title: 'Feature on Homepage?', value: job.feature_homepage ? 'Yes' : 'No' },
          { title: 'Feature on Job Digest?', value: job.feature_job_digest ? 'Yes' : 'No' },
          { title: 'Value', value: dollar_value.to_s },
          job.extra_packages.present? ? { title: 'Extra Packages', value: job.extra_packages.join(', '), short: true } : nil,
        ].compact,
      },
    )
  end

  def dollar_value
    val = subscription.as_json.dig('items', 'data', 0, 'price', 'unit_amount') || 0
    ActionController::Base.helpers.number_to_currency(val / 100)
  end
end
