# frozen_string_literal: true

module UpcomingPages::Webhook
  extend self

  def call(subscriber, event)
    data = {
      version: 1,
      type: event,
      subscriberId: subscriber.id,
      data: {
        email: subscriber.email,
        username: nil,
        headline: nil,
        followersCount: nil,
      },
    }

    if subscriber.user.present?
      data[:data][:username] = subscriber.user.username
      data[:data][:name] = subscriber.user.name
      data[:data][:headline] = subscriber.user.headline
      data[:data][:followersCount] = subscriber.user.follower_count
    end

    RestClient.post subscriber.upcoming_page.webhook_url, data.to_json, content_type: :json
  rescue RestClient::NotFound
    nil
  end
end
