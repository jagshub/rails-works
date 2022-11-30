# frozen_string_literal: true

module TwitterApi::AcquireToken
  RATE_LIMIT_WINDOW = 15.minutes
  MAX_RETRIES = 5

  extend self

  def call(user = nil)
    if user.present?
      scope = AccessToken.twitter.available_for_sync.where(user_id: user.id)
      token = acquire_record(scope)
      return token if token.present?
    end

    1.upto(MAX_RETRIES) do
      scope = AccessToken.twitter.available_for_sync.order('unavailable_until ASC NULLS FIRST')
      token = acquire_record(scope)
      return token if token.present?
    end

    raise(TwitterApi::OutOfTokensError)
  end

  private

  def acquire_record(relation)
    relation.model.transaction do
      record = relation.first || return
      record.update! unavailable_until: Time.current + RATE_LIMIT_WINDOW
      record
    end
  end
end
