# frozen_string_literal: true

module Notifications::Notifiers::ShipNewConversationMessageNotifier
  extend Notifications::Notifiers::BaseNotifier
  extend self

  def channels
    {
      slack: {
        priority: :mandatory,
        user_setting: false,
      },
    }
  end

  def subscriber_ids(upcoming_page_conversation_message)
    upcoming_page_conversation_message
      .upcoming_page.maintainers
      .select { |user| SlackBot.active_for?(user) }
      .map { |user| user.subscriber&.id }
      .compact
  end

  def fan_out?(upcoming_page_conversation_message)
    upcoming_page_conversation_message.upcoming_page_subscriber_id?
  end

  class SlackPayload < Notifications::Channels::Slack::Payload
    def text
      "#{ pick_salutation } New message email reply."
    end

    def icon_emoji
      ':boat:'
    end

    def attachments
      reply = notification.notifyable
      subscriber = reply.subscriber

      [attachment(
        author_icon: subscriber.avatar_url,
        author_link: Routes.my_ship_contact_url(subscriber.ship_contact_id),
        author_name: subscriber.name,
        footer: reply.upcoming_page.name,
        text: reply.body.squish.truncate(250),
        title: reply.upcoming_page_message.subject,
        title_link: Routes.my_upcoming_page_conversation_message_url(reply),
        ts: reply.created_at.to_i,
      )]
    end
  end
end
