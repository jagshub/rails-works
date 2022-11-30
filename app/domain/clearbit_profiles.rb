# frozen_string_literal: true

module ClearbitProfiles
  extend self

  def enrich_from_webhook_payload(payload)
    ClearbitProfiles::Enrich.from_payload(payload)
  end

  def enrich_from_email(email, refresh: false, stream: false)
    ClearbitProfiles::Enrich.from_email(
      email,
      refresh: refresh,
      stream: stream,
    )
  end

  def enqueue_for_enrich(user)
    return unless Rails.env.production?

    ClearbitProfiles::EnrichQueue.push(user)
  end
end
