# frozen_string_literal: true

module Notifications::Channels::MobilePush::Payload
  extend self

  DEFAULT_HEADING = 'Product Hunt'
  DEFAULT_DELIVERY = 'last-active'

  def call(notification:, tokens:)
    notifier = notification.notifier
    subscriber = notification.subscriber

    thumbnail_url = thumbnail_url_for(notification)
    delivery = delivery_for(notification)

    {
      include_player_ids: tokens,
      headings: { en: notifier.push_text_heading(notification).presence || DEFAULT_HEADING },
      contents: { en: notifier.push_text_body(notification).presence || notifier.push_text_oneliner(notification) },
      mutable_content: thumbnail_url.present?,
      data: {
        subscriber_id: subscriber.id,
        attachment_url: thumbnail_url,
        delivered_via: delivery,
        kind: notification.kind,
        notification_event_id: notification.id,
        # NOTE(rstankov): Used by new mobile app after: 2022-09-01
        route: notifier.weblink_url(notification),
      },
      delayed_option: delivery, # https://documentation.onesignal.com/docs/sending-notifications#intelligent-delivery
    }
  end

  private

  def thumbnail_url_for(notification)
    notification.notifier.thumbnail_url(notification)
  end

  def delivery_for(notification)
    channel_name = notification.channel_name.to_sym
    settings = notification.notifier.channels[channel_name]
    settings&.fetch(:delivery, DEFAULT_DELIVERY)
  end
end
