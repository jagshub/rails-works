# frozen_string_literal: true

module Mobile::Graph::Types
  class SettingsType < BaseObject
    graphql_name 'Settings'

    field :name, String, null: true
    field :username, String, null: true
    field :about, String, null: true
    field :email, String, null: true
    field :headline, String, null: true
    field :website_url, String, null: true
    field :links, [Mobile::Graph::Types::UserLinkType], null: true
    field :header, String, null: true
    field :avatar, String, null: true
    field :private_profile, Boolean, null: false
    field :can_change_username, resolver: Mobile::Graph::Utils::CanResolver.build(:change_username, &:user)
    field :can_change_email, resolver: Mobile::Graph::Utils::CanResolver.build(:change_email, &:user)
    field :user, UserType, null: false
    field :daily_newsletter_subscription, String, null: true
    field :jobs_newsletter_subscription, String, null: true
    field :stories_newsletter_subscription, String, null: true

    delegate :user, to: :object
    delegate :links, to: :user

    def daily_newsletter_subscription
      object&.user&.subscriber ? context.current_user.subscriber.newsletter_subscription : ''
    end

    def jobs_newsletter_subscription
      object&.user&.subscriber ? context.current_user.subscriber.jobs_newsletter_subscription : ''
    end

    def stories_newsletter_subscription
      object&.user&.subscriber ? context.current_user.subscriber.stories_newsletter_subscription : ''
    end
  end
end
