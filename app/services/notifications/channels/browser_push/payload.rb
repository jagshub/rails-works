# frozen_string_literal: true

class Notifications::Channels::BrowserPush::Payload
  DEFAULT_ICON = S3Helper.image_url('category-tech/kitty.png')
  DEFAULT_HEADING = 'Product Hunt'
  DEFAULT_DELIVERY = 'last-active'

  attr_reader :notification, :subscriber, :notifier

  class << self
    def from_notification(notification_event)
      new(notification_event).to_hash
    end
  end

  def initialize(notification)
    @notification = notification
    @subscriber = notification.subscriber
    @notifier = notification.notifier
  end

  def to_hash
    {
      include_player_ids: [subscriber.browser_push_token],
      headings: { en: heading },
      contents: { en: content },
      url: weblink_url,
      chrome_web_icon: icon,
      firefox_icon: icon,
      data: {
        kind: notification.kind,
        channel: notification.channel_name,
        subscriber_id: subscriber.id,
        notification_event_id: notification.id,
        delivered_via: delivery,
      },
      delayed_option: delivery, # https://documentation.onesignal.com/docs/sending-notifications#intelligent-delivery
    }
  end

  private

  def heading
    notifier.push_text_heading(notification).presence || DEFAULT_HEADING
  end

  def content
    notifier.push_text_body(notification).presence || notifier.push_text_oneliner(notification)
  end

  def icon
    notifier.thumbnail_url(notification).presence || DEFAULT_ICON
  end

  def channel_name
    notification.channel_name.to_sym
  end

  def settings
    notifier.channels[channel_name]
  end

  def delivery
    settings&.fetch(:delivery, DEFAULT_DELIVERY)
  end

  def weblink_url
    url = notifier.weblink_url(notification)
    tagging_params = Metrics.url_tracking_params(medium: :browser_notification, object: notification)

    url + '?' + tagging_params.to_query
  end
end
