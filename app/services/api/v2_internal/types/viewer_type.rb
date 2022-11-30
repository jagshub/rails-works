# frozen_string_literal: true

module API::V2Internal::Types
  class ViewerType < BaseObject
    field :id, ID, null: false
    field :confirmed_age, Boolean, null: false
    field :settings, API::V2Internal::Types::SettingsType, null: false
    field :user, API::V2Internal::Types::UserType, null: false
    field :activity_feed_items_unread_count, Int, null: false
    field :activity_feed_items_last_seen_at, API::V2Internal::Types::DateTimeType, method: :notification_feed_last_seen_at, null: true
    field :is_admin, Boolean, null: false, resolver_method: :admin?

    field :collections, API::V2Internal::Types::CollectionType.connection_type, max_page_size: 50, resolver: API::V2Internal::Resolvers::Collections::CollectionsResolver, connection: true

    def user
      object
    end

    def settings
      My::UserSettings.new(object)
    end

    def activity_feed_items_unread_count
      object.notification_feed_items_unread_count.to_i
    end

    def admin?
      object.id == context[:current_user]&.id && object.admin?
    end
  end
end
