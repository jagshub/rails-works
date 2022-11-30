# frozen_string_literal: true

module Notifications::Notifiers::ShipNewSubscriberNotifier
  extend Notifications::Notifiers::BaseNotifier
  extend self

  def channels
    {
      slack: {
        # NOTE(rstankov): Give a chance for clearbit data to be collected
        delay: 5.minutes,
        priority: :mandatory,
        user_setting: false,
      },
    }
  end

  def subscriber_ids(subscriber)
    subscriber
      .upcoming_page
      .maintainers
      .select { |user| SlackBot.active_for?(user) }
      .map { |user| user.subscriber&.id }
      .compact
  end

  class SlackPayload < Notifications::Channels::Slack::Payload
    def text
      "#{ pick_salutation } You have a new subscriber. 🙌\n#{ total_subscribers_text }"
    end

    def icon_emoji
      ':boat:'
    end

    def attachments
      subscriber = notification.notifyable
      upcoming_page = subscriber.upcoming_page

      [attachment(
        author_icon: subscriber.avatar_url,
        author_link: Routes.my_ship_contact_url(subscriber.ship_contact_id),
        author_name: subscriber.name,
        fields: attachment_fields_for(subscriber),
        footer: subscriber.upcoming_page.name,
        title: 'Subscriber details',
        title_link: Routes.my_ship_contact_url(subscriber.ship_contact_id),
        ts: subscriber.updated_at.to_i,
        actions: [
          action('View details', Routes.my_ship_contact_url(subscriber.id)),
          action('Send a message', Routes.my_upcoming_new_message_url(upcoming_page, subscriber)),
        ],
      )]
    end

    private

    def total_subscribers_text
      upcoming_page = notification.notifyable.upcoming_page
      "_Now you have *#{ upcoming_page.subscriber_count } #{ 'subscriber'.pluralize(upcoming_page.subscriber_count) }* for #{ upcoming_page.name }._"
    end

    def attachment_fields_for(subscriber)
      fields = []
      fields << attachment_field('Email', subscriber.email)

      user = subscriber.user
      if user
        fields << attachment_field('Name', user.name)
        fields << attachment_field('Username', user.username)
        fields << attachment_field('Followers', user.follower_count)
      end

      profile = subscriber.contact.clearbit_person_profile

      if profile
        fields << attachment_field('Name', profile.name) if profile.name.present? && !user
        fields << attachment_field('Bio', profile.bio) if profile.bio.present?
        fields << attachment_field('Company', profile.employment_name) if profile.employment_name.present?
        fields << attachment_field('Country', profile.geo_country) if profile.geo_country.present?
        fields << attachment_field('Twitter', "@#{ profile.twitter_handle }") if profile.twitter_handle.present?
      end

      fields
    end
  end
end
