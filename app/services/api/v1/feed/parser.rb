# frozen_string_literal: true

class API::V1::Feed::Parser
  def parse(notifications)
    notifications.map do |notification|
      convert_notification_to_api_format(notification)
    end.compact
  end

  private

  # Note (Mike Coutermarsh): We do this to maintain the API contract. We've changed the backend for
  #  notifications, ~multiple~ times. So this forces the latest version to fit the first design of the API.
  def convert_notification_to_api_format(notification)
    build_item(
      body: notification.verb,
      sentence: notification.sentence,
      reference: notification.object,
      from_user: notification.actors[0],
      timestamp: notification.updated_at,
      seen: notification.seen?,
    )
  end

  def build_item(options)
    return if options[:from_user].nil?

    ::API::V1::Feed::Item.new(options)
  end
end
