# frozen_string_literal: true

module Subscribers
  extend self

  def register_first_time_user(attributes)
    subscriber = Subscribers::Register.call(attributes)
    Subscribers::Verification.send_verification subscriber, first_time: true

    subscriber
  end

  def register_and_verify(attributes)
    subscriber = Subscribers::Register.call(attributes)
    Subscribers::Verification.send_verification subscriber

    subscriber
  end

  def register(attributes)
    Subscribers::Register.call(attributes)
  end

  def send_verification_email(subscriber:, first_time: false, skip_email_link_tracking: false)
    Subscribers::Verification.send_verification(
      subscriber,
      first_time: first_time,
      skip_email_link_tracking: skip_email_link_tracking,
    )
  end

  def verify_by_token(token:, user:)
    Subscribers::Verification.verify_by_token token, user
  end

  def unverify_email(subscriber:)
    Subscribers::Verification.unverify subscriber
  end

  def needs_verification?(subscriber:)
    Subscribers::Verification.needs_verification? subscriber
  end
end
