# frozen_string_literal: true

class Notifications::Channels::Slack::Payload
  class << self
    def from_notification(notification)
      webhook_url = notification.subscriber.slack_webhook_url
      raise ArgumentError, 'Missing slack webhook url' if webhook_url.blank?

      generator = "#{ notification.notifier.name }::SlackPayload".safe_constantize
      payload = generator.new(notification)

      {
        url: webhook_url,
        message: payload.to_h,
      }
    end
  end

  attr_reader :notification

  def initialize(notification)
    @notification = notification
  end

  def text
    nil
  end

  def username
    nil
  end

  def icon_emoji
    nil
  end

  def attachments
    nil
  end

  def to_h
    {
      text: text,
      username: username,
      mrkdwn: true,
      icon_emoji: icon_emoji,
      attachments: attachments&.compact,
    }.compact
  end

  private

  DEFAULT_COLOR = '#e8e8e8'

  # NOTE(rstankov): Available fields: https://api.slack.com/docs/message-attachments
  def attachment(fallback: nil, color: nil, title:, title_link:, author_link: nil, **args)
    {
      fallback: fallback || title,
      color: color || DEFAULT_COLOR,
      title: title,
      title_link: add_tracking(title_link),
      author_link: add_tracking(author_link),
    }.merge(**args).compact
  end

  def attachment_field(title, value, short: true)
    { title: title, value: value, short: short }
  end

  def action(text, url)
    { text: text, url: add_tracking(url), type: 'button' }
  end

  def add_tracking(url)
    return if url.blank?

    Metrics.url_tracking_params(url: url, medium: :slack, object: notification)
  end

  SALUTATIONS = [
    'Hi, friends!',
    'Howdy!',
    'Hey, there!',
    'Salutations!',
  ].freeze

  def pick_salutation
    SALUTATIONS.sample
  end
end
