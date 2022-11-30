# frozen_string_literal: true

module Notifications::Notifiers::ShipNewMessageCommentNotifier
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

  def subscriber_ids(comment)
    comment
      .subject
      .upcoming_page
      .maintainers
      .select { |user| SlackBot.active_for?(user) }
      .map { |user| user.subscriber&.id }
      .compact
  end

  def fan_out?(comment)
    comment.subject_type == UpcomingPageMessage.name
  end

  class SlackPayload < Notifications::Channels::Slack::Payload
    def text
      "#{ pick_salutation } New message comment."
    end

    def icon_emoji
      ':boat:'
    end

    def attachments
      comment = notification.notifyable
      message = comment.subject

      [attachment(
        author_icon: Users::Avatar.url_for_user(comment.user),
        author_link: author_link(comment),
        author_name: comment.user.name,
        title: message.subject,
        title_link: Routes.my_upcoming_page_message_url(message.upcoming_page.slug, message.id),
        text: comment.body.squish.truncate(250),
        ts: comment.created_at.to_i,
        footer: message.upcoming_page.name,
      )]
    end

    private

    def author_link(comment)
      subscriber = comment.subject.upcoming_page.subscribers.for_user(comment.user_id).first

      if subscriber
        Routes.my_ship_contact_url(subscriber.ship_contact_id)
      else
        Routes.profile_url(comment.user)
      end
    end
  end
end
