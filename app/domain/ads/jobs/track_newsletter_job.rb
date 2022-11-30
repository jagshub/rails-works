# frozen_string_literal: true

class Ads::Jobs::TrackNewsletterJob < ApplicationJob
  include ActiveJobHandleDeserializationError

  queue_as :tracking

  def perform(subject:, event:, request_info: {})
    Ads.fill_newsletter(
      subject: subject,
      event_type: event,
      request_info: request_info,
    )
  end
end
