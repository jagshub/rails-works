# frozen_string_literal: true

module Subscribers::Verification
  extend self

  def send_verification(subscriber, first_time: false, skip_email_link_tracking: false)
    return unless needs_verification? subscriber

    ActiveRecord::Base.transaction do
      token = generate_verification_token subscriber

      subscriber.update!(
        email_confirmed: false,
        verification_token: token,
        verification_token_generated_at: Time.current,
      )
    end

    if first_time
      UserMailer.email_verification(
        subscriber,
        skip_tracking: skip_email_link_tracking,
      ).deliver_later
    else
      UserMailer.email_updated_verification(
        subscriber,
        skip_tracking: skip_email_link_tracking,
      ).deliver_later
    end
  rescue ActiveRecord::RecordInvalid => e
    ErrorReporting.report_error(e, extra: { subscriber: subscriber.as_json })
  end

  def verify_by_token(token, user)
    subscriber = Subscriber.unverified.find_by verification_token: token

    return :record_not_found if subscriber.blank? || subscriber.user != user
    return :token_expired unless subscriber.verification_token_valid?
    return true unless needs_verification? subscriber

    subscriber.update!(
      email_confirmed: true,
      verification_token: nil,
      verification_token_generated_at: nil,
    )

    send_welcome subscriber

    true
  end

  def unverify(subscriber)
    subscriber.update!(
      email_confirmed: false,
      verification_token: nil,
      verification_token_generated_at: nil,
    )
  end

  def needs_verification?(subscriber)
    subscriber.persisted? &&
      subscriber.user.present? &&
      subscriber.email.present? &&
      !subscriber.email_confirmed
  end

  private

  def generate_verification_token(subscriber)
    HasUniqueCode.generate_code(
      subscriber,
      field_name: :verification_token,
      length: 32,
    )
  end

  def send_welcome(subscriber)
    user = subscriber.user
    return if user.blank? || user.welcome_email_sent? || pre_feature_user?(user)

    Iterable.trigger_event('user_verified_mail', email: subscriber.email, user_id: subscriber.user.id)
  end

  WELCOME_EMAIL_FIELD_ADDED_DATE = '2020-11-11'

  def pre_feature_user?(user)
    user.created_at < WELCOME_EMAIL_FIELD_ADDED_DATE.to_date
  end
end
