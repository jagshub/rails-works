# frozen_string_literal: true

class ShipMailer < ApplicationMailer
  def stripe_discounts(account)
    email_campaign_name('ship_stripe_discounts')

    @account = account
    @discount = Ships::StripeDiscountCode.for(account)

    mail to: account.user.email, subject: 'Stripe Promo Codes from Product Hunt ⛵️'
  end

  def trial_expired(account)
    email_campaign_name('ship_trial_expired')

    @account = account

    @recent_subscribers = fetch_recent_subscribers_for(account)

    mail(
      to: account.user.email,
      subject: 'Your Product Hunt Ship Trial Account has Expired ⛵️',
      reply_to: CommunityContact::PREMIUM_SHIP,
    )
  end

  def subscription_downgraded(account)
    email_campaign_name('ship_subscription_downgraded')

    @account = account

    mail(
      to: account.user.email,
      subject: "Your Product Hunt Ship Subscription couldn't be charged due to payment error.",
      reply_to: CommunityContact::PREMIUM_SHIP,
    )
  end

  private

  def fetch_recent_subscribers_for(account)
    account.upcoming_pages.map do |upcoming_page|
      count = upcoming_page.subscribers.confirmed.where('created_at > ?', 1.week.ago).count
      [count, upcoming_page] if count >= 10
    end.compact.max_by(&:first)
  end
end
