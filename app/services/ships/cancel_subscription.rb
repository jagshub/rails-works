# frozen_string_literal: true

class Ships::CancelSubscription
  def self.call(*args)
    new(*args).call
  end

  DEFAULT_REASON = 'Cancelled Ship Subscription'

  attr_reader :user, :moderator, :reason, :at_period_end, :trash_upcoming_pages, :till_the_end_of_the_billing_period
  def initialize(user:, reason: nil, moderator: nil, at_period_end: true, trash_upcoming_pages: false, till_the_end_of_the_billing_period: true)
    @user = user
    @reason = reason
    @moderator = moderator
    @at_period_end = at_period_end
    @trash_upcoming_pages = trash_upcoming_pages
    @till_the_end_of_the_billing_period = till_the_end_of_the_billing_period
  end

  def call
    return false if user.ship_subscription.blank?

    ActiveRecord::Base.transaction do
      track_event
      record_reason

      if user.ship_subscription.trial?
        cancel_trial
      else
        cancel_subscription
        notify_via_slack
      end

      trash_upcoming_pages_if_needed
    end

    true
  end

  private

  def track_event
    Ships::Tracking.record(
      user: user,
      funnel_step: Ships::Tracking::CANCEL,
      meta: {
        trial: trial?,
      },
    )
  end

  def trial?
    user.ship_subscription.trial?
  end

  def record_reason
    if moderator
      ModerationLog.create!(
        reference: user,
        moderator: moderator,
        message: reason || DEFAULT_REASON,
      )
    elsif reason
      ShipCancellationReason.create!(
        user: user,
        billing_plan: user.ship_subscription.billing_plan,
        reason: reason,
      )
    end
  end

  def cancel_trial
    Ships::DowngradeSubscription.call(user)
  end

  def cancel_subscription
    stripe_subscription = Ships::Payments::Subscription.cancel!(user.ship_subscription, at_period_end: at_period_end, till_the_end_of_the_billing_period: till_the_end_of_the_billing_period)

    user.ship_subscription.update!(
      cancelled_at: Time.zone.now,
      ends_at: at_period_end && stripe_subscription['current_period_end'] ? Time.zone.at(stripe_subscription['current_period_end']) : Time.zone.now,
    )
  rescue Stripe::InvalidRequestError => e
    raise e unless e.message.include? 'No such subscription'

    user.ship_subscription.update!(
      cancelled_at: Time.zone.now,
      ends_at: Time.zone.now,
    )
  end

  def notify_via_slack
    Ships::Slack::CancelSubscription.call(
      ship_subscription: user.ship_subscription,
      moderator: moderator,
      reason: reason,
    )
  end

  def trash_upcoming_pages_if_needed
    user.ship_account.upcoming_pages.each(&:trash) if trash_upcoming_pages
  end
end
