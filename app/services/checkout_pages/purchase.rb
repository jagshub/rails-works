# frozen_string_literal: true

class CheckoutPages::Purchase
  CURRENCY = 'usd'

  attr_reader :inputs, :user, :billing_email, :stripe_token, :checkout_page_log, :customer

  class << self
    def call(inputs:, user:)
      new(inputs: inputs, user: user).call
    end
  end

  def initialize(inputs:, user:)
    @inputs = inputs
    @user = user
    @billing_email = inputs[:billing_email]
    @stripe_token = inputs[:stripe_token_id]
  end

  def call
    CheckoutPage.transaction do
      create_log
      perform_purchase
    end

    begin
      send_slack_notification
    rescue StandardError => e
      ErrorReporting.report_error(e)
    end

    customer
  end

  private

  def create_log
    @checkout_page_log = CheckoutPageLog.create!(
      user: user,
      checkout_page: checkout_page,
      billing_email: billing_email,
    )
  end

  def perform_purchase
    @customer = External::StripeApi.create_customer(
      email: billing_email,
      stripe_token_id: stripe_token,
      extra: inputs[:extra],
    )

    if checkout_page.one_time_payment?
      order = Stripe::Order.create(
        currency: CURRENCY,
        customer: customer.id,
        email: billing_email,
        items: [
          {
            type: 'sku',
            parent: checkout_page.sku,
          },
        ],
      )

      order.pay(customer: customer.id)
    else
      Stripe::Subscription.create(
        customer: customer.id,
        items: [
          {
            plan: checkout_page.sku,
          },
        ],
      )
    end
  end

  def checkout_page
    @checkout_page ||= CheckoutPage.friendly.find(inputs[:checkout_page_id])
  end

  def send_slack_notification
    title = "New purchase from @#{ user.username }"

    SlackNotify.call(
      channel: :checkout_pages_activity,
      username: user.username,
      icon_emoji: ':money_mouth_face:',
      attachment: {
        author_name: user.name,
        author_link: Routes.profile_url(user),
        author_icon: Users::Avatar.url_for_user(user),
        fallback: title,
        color: '#66be00',
        title: title,
        title_link: Routes.admin_checkout_page_log_url(checkout_page_log),
        fields: [
          { title: 'Checkout Page', value: checkout_page.name, short: true },
          { title: 'Stripe SKU', value: checkout_page.sku, short: true },
          { title: 'Billing Email', value: billing_email, short: true },
          { title: 'User Email', value: user.email, short: true },
        ],
      },
    )
  end
end
