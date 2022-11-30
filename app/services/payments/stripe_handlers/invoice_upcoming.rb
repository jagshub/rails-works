# frozen_string_literal: true

module Payments::StripeHandlers::InvoiceUpcoming
  extend self

  def call(subscription)
    return if subscription.nil?

    last_renew_notice_sent_day = subscription.renew_notice_sent_at&.beginning_of_day
    return if last_renew_notice_sent_day.present? && Time.zone.now - last_renew_notice_sent_day < 7.days

    subscription.update!(renew_notice_sent_at: Time.zone.now)
    PaymentsMailer.subscription_renewal_notice(subscription).deliver_later
  end
end
