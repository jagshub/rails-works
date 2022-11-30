# frozen_string_literal: true

class Ships::Slack::SubscriptionNotification < Ships::Slack::Notification
  def fields
    billing_info = ShipBillingInformation.find_by(user: author)
    invite_code = billing_info&.ship_invite_code&.code || 'N/A'

    [
      { title: 'Stripe Customer ID', value: billing_info&.stripe_customer_id, short: true },
      { title: 'Plan', value: ship_subscription.billing_plan, short: true },
      { title: 'Billing Period', value: ship_subscription.billing_period, short: true },
      { title: 'Invite Code', value: invite_code, short: true },
      { title: 'Instant Access Page', value: author.ship_instant_access_page&.slug || 'N/A', short: true },
      { title: 'User ID', value: author.id, short: true },
      { title: 'Username', value: author.username, short: true },
      { title: 'Email', value: author.email, short: true },
      { title: 'Billing Email', value: billing_info&.billing_email, short: true },
    ]
  end
end
