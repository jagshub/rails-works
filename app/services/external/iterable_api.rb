# frozen_string_literal: true

# Note(Bharat): Login to iterable.com using your PH email. If you do not have access, ask Michael/Sarah to give you access.
module External::IterableAPI
  extend self

  # Note(Bharat): Documentation https://api.iterable.com/api/docs#events_track
  def trigger_event(event_name:, email:, user_id:, data_fields: {}, campaign_id: nil, template_id: nil)
    call_api(
      path: '/events/track',
      method: :post,
      data: {
        eventName: event_name,
        userId: user_id,
        email: email,
        dataFields: data_fields,
        campaignId: campaign_id,
        templateId: template_id,
      }.compact,
    )
  end

  # Note(JL): Documentation https://api.iterable.com/api/docs#events_trackBulk
  def bulk_trigger_events(events: [])
    call_api(
      path: '/events/trackBulk',
      method: :post,
      data: {
        events: events,
      }.compact,
    )
  end

  # Note(Bharat): Documentation https://api.iterable.com/api/docs#users_updateUser
  def upsert_user(email:, user_id:, data_fields: {})
    call_api(
      path: '/users/update',
      method: :post,
      data: {
        email: email,
        userId: user_id.to_s,
        dataFields: data_fields,
      },
    )
  end

  # Note(Bharat): Documentation https://api.iterable.com/api/docs#users_bulkUpdateUser
  def bulk_update(users:)
    call_api(
      path: '/users/bulkUpdate',
      method: :post,
      data: {
        users: users,
      },
    )
  end

  # Note(Bharat): Documentation https://api.iterable.com/api/docs#users_bulkUpdateSubscriptions
  def bulk_update_subscriptions(users:)
    call_api(
      path: '/users/bulkUpdateSubscriptions',
      method: :post,
      data: {
        updateSubscriptionsRequests: users,
      },
    )
  end

  # Note(Bharat): Documentation https://api.iterable.com/api/docs#users_delete
  def remove_user_from_iterable(email:)
    call_api(path: "/users/#{ email }", method: :delete)
  end

  # Note(Bharat): Documentation https://api.iterable.com/api/docs#users_updateSubscriptions
  def update_user_subscriptions(email:, user_id:, unsubscribed_message_type_ids:, subscribed_message_type_ids:)
    call_api(
      path: '/users/updateSubscriptions',
      method: :post,
      data: {
        email: email,
        userId: user_id,
        unsubscribedMessageTypeIds: unsubscribed_message_type_ids,
        subscribedMessageTypeIds: subscribed_message_type_ids,
      },
    )
  end

  private

  def call_api(path:, data: {}, method: :post)
    return if Rails.env.test?

    url = "https://api.iterable.com/api#{ path }"
    headers = {
      content_type: :json,
      accept: :json,
      Api_Key: Config.secret(:iterable_api_key),
    }
    log(data.to_json, headers, url)

    if method == :delete
      RestClient.delete url, headers
    else
      RestClient.send method, url, data.to_json, headers
    end
  end

  def log(data, headers, url)
    Rails.logger.info 'Calling iterable'
    Rails.logger.info "data: #{ data }"
    Rails.logger.info "headers: #{ headers }"
    Rails.logger.info "URL: #{ url }"
  end
end
