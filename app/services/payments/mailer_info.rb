# frozen_string_literal: true

module Payments::MailerInfo
  HANDLERS = {
    'founder_club' => ::FounderClub.mailer_info,
  }.freeze

  extend self

  def for_event(event:, subscription:)
    handler = HANDLERS[subscription.plan.project]
    handler = self unless handler.respond_to?(event)

    info = handler.public_send(event, subscription)
    info[:reply_to] ||= CommunityContact::PAYMENTS
    info
  end

  def subscription_created(subscription)
    { subject: "Congratulations! You've successfully subscribed to #{ subscription.plan.name }" }
  end

  def subscription_canceled_by_user(subscription)
    { subject: "You've successfully canceled your subscription to #{ subscription.plan.name }" }
  end

  def subscription_canceled_by_stripe(subscription)
    { subject: "Your subscription to #{ subscription.plan.name } couldn't be charged due to payment error." }
  end

  def subscription_renewal_notice(subscription)
    { subject: "Your subscription to #{ subscription.plan.name } will be auto renewed soon" }
  end
end
