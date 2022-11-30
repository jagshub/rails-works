# frozen_string_literal: true

module External::OneSignalApi
  extend self

  API_URL = 'https://onesignal.com/api/v1/notifications'

  def send(data)
    data[:app_id] = ENV['ONESIGNAL_VENDOR_APP_KEY']
    headers = {
      content_type: :json,
      accept: :json,
      authorization: "Basic #{ ENV['ONESIGNAL_VENDOR_REST_API_KEY'] }",
    }

    return log(data, headers) if Rails.env.development?

    RestClient.post API_URL, data.to_json, headers
  end

  def fetch_notifications(offset:, kind:)
    notification_req = fetch_page(offset: offset, kind: kind)
    return if notification_req.nil? || notification_req.code != 200

    JSON.parse(notification_req.body)['notifications']
  end

  private

  def log(data, headers)
    # Note(andreasklinger): Needed because we can't use production push tokens w/ development api keys
    Rails.logger.info 'Sending notification'
    Rails.logger.info "data: #{ data }"
    Rails.logger.info "headers: #{ headers }"
  end

  # https://documentation.onesignal.com/reference/view-notifications
  def fetch_page(**options)
    HandleNetworkErrors.call(fallback: nil) do
      options[:app_id] = ENV['ONESIGNAL_VENDOR_APP_KEY']
      options[:accept] = :json

      RestClient.get API_URL, params: options, Authorization: "Basic #{ ENV['ONESIGNAL_VENDOR_REST_API_KEY'] }"
    end
  end
end
