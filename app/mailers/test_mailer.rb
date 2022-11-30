# frozen_string_literal: true

class TestMailer < ApplicationMailer
  include Admin::MailTest

  DELIVERY_METHODS = {
    default: {
      from: CommunityContact.default_from,
    },
    community: {
      from: CommunityContact.default_from,
      delivery_method: CommunityContact.delivery_method_options,
    },
    jobs: {
      from: 'Jobs Digest <jobs@producthunt.com>',
      delivery_method: Config.job_email_delivery_options,
    },
    ship: {
      from: 'Test Upcoming Page <test-upcoming-page@ship.producthunt.com>',
      delivery_method: Config.ship_email_delivery_options,
    },
  }.freeze

  def test(to:, subject:, body:, delivery_method: :default)
    options = DELIVERY_METHODS.fetch(delivery_method.to_sym)

    @body = body

    mail(
      to: to,
      from: options[:from],
      subject: subject,
      delivery_method_options: options[:delivery_method],
    )
  end

  def mailjet_payload_test(user, payload:)
    return unless user.admin?

    @payload = payload
    email_event_payload test_email_event_payload(payload)

    mail to: user.subscriber.email, subject: 'Mailjet payload test'
  end
end
