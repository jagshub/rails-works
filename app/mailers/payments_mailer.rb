# frozen_string_literal: true

class PaymentsMailer < ApplicationMailer
  SUBSCRIPTION_CREATED_CAMPAIGN = 'Payments Subscription Created'
  SUBSCRIPTION_CANCELED_BY_USER_CAMPAIGN = 'Payments Subscription Canceled By User'
  SUBSCRIPTION_CANCELED_BY_STRIPE_CAMPAIGN = 'Payments Subscription Canceled By Stripe'
  SUBSCRIPTION_RENEWAL_NOTICE_CAMPAIGN = 'Payments Subscription Renewal Notice'

  def subscription_created(subscription)
    @user = subscription.user
    @plan = subscription.plan

    email_campaign_name SUBSCRIPTION_CREATED_CAMPAIGN

    send_mail(
      event: 'subscription_created',
      to: @user.email,
      subscription: subscription,
    )
  end

  def subscription_canceled_by_user(subscription)
    @user = subscription.user
    @plan = subscription.plan

    email_campaign_name SUBSCRIPTION_CANCELED_BY_USER_CAMPAIGN

    send_mail(
      event: 'subscription_canceled_by_user',
      to: @user.email,
      subscription: subscription,
    )
  end

  def subscription_canceled_by_stripe(subscription)
    @user = subscription.user
    @plan = subscription.plan

    email_campaign_name SUBSCRIPTION_CANCELED_BY_STRIPE_CAMPAIGN

    send_mail(
      event: 'subscription_canceled_by_stripe',
      to: @user.email,
      subscription: subscription,
    )
  end

  def subscription_renewal_notice(subscription)
    @user = subscription.user
    @plan = subscription.plan

    email_campaign_name SUBSCRIPTION_RENEWAL_NOTICE_CAMPAIGN

    send_mail(
      event: 'subscription_renewal_notice',
      to: @user.email,
      subscription: subscription,
    )
  end

  private

  def send_mail(event:, to:, subscription:)
    mail_info = Payments::MailerInfo.for_event(event: event, subscription: subscription)
    mail(
      to: to,
      subject: mail_info[:subject],
      reply_to: mail_info[:reply_to],
    )
  end
end
