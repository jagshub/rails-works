# frozen_string_literal: true

class WebHooks::OptinmonsterSignupWorker
  include Sidekiq::Worker

  def perform(payload)
    return if payload.nil?

    email = EmailValidator.normalize(payload['lead']['email'])

    return if email.blank?

    Newsletter::Subscriptions.set email: email, status: Newsletter::Subscriptions::DAILY, tracking_options: { source: :promotion, source_details: payload['campaign']['slug'] }
  end
end
