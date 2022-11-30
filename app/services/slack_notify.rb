# frozen_string_literal: true

# NOTE(rstankov): Send message in Slack channel via Webhook
#
#  Slack documentation on Webhooks
#     https://api.slack.com/messaging/webhooks
#
#  How to integrate with PH Slack
#     https://www.notion.so/teamhome1431/How-to-integrate-with-Slack-8359926d1be14d548080d6d3d717cc9d
#

module SlackNotify
  extend self

  CHANNELS = {
    admin_livefeed: ENV['SLACK_ADMIN_FEED_WEBHOOK'],
    checkout_pages_activity: ENV['SLACK_CHECKOUT_PAGE_ACTIVITY_WEBHOOK'],
    engineering: ENV['SLACK_WEB_CHANNEL_WEBHOOK'],
    featured_posts: ENV['SLACK_FEATURED_POSTS_WEBHOOK'],
    flagged: ENV['SLACK_FLAGGED_WEBHOOK'],
    gdpr: ENV['SLACK_GDPR_WEBHOOK'],
    pending_discussions: ENV['SLACK_PENDING_DISCUSSIONS_WEBHOOK'],
    post_activity: ENV['SLACK_POST_ACTIVITY_WEBHOOK'],
    reviews_activity: ENV['SLACK_REVIEWS_ACTIVITY_WEBHOOK'],
    ship_activity: ENV['SLACK_SHIP_ACTIVITY_WEBHOOK'],
    ship_community_activity: ENV['SLACK_SHIP_COMMUNITY_ACTIVITY_WEBHOOK'],
    sales_operations: ENV['SLACK_NO_ACTIVE_ADS_WEBHOOK'],
  }.freeze

  def call(channel:, text: nil, username: nil, icon_emoji: nil, icon_url: nil, attachment: nil, blocks: nil, deliver_now: false)
    validate_channel(channel)
    validate_attachment(attachment) if attachment

    message = {
      text: text,
      username: username,
      icon_emoji: icon_emoji,
      icon_url: icon_url,
      attachments: attachment ? [attachment] : nil,
      blocks: blocks,
    }.compact

    raise "Can't send empty message" if message.empty?

    if deliver_now
      SlackNotify::DeliveryWorker.perform_now(channel: channel.to_s, message: message)
    else
      SlackNotify::DeliveryWorker.perform_later(channel: channel.to_s, message: message)
    end
  end

  private

  def validate_channel(channel)
    raise "Invalid channel: '#{ channel }' (Available: #{ CHANNELS.keys })" unless CHANNELS.key?(channel.to_sym)
  end

  ATTACHMENT_KEYS = %i(
    author_icon
    author_link
    author_name
    color
    fallback
    fields
    text
    title
    title_link
  ).freeze

  def validate_attachment(attachment)
    extra_keys = attachment.keys - ATTACHMENT_KEYS
    raise "Invalid attachment key(s): #{ extra_keys } (Allowed: #{ ATTACHMENT_KEYS })" if extra_keys.present?
  end
end
