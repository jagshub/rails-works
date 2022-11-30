# frozen_string_literal: true

module API::V2Internal::Mutations
  class UserActivitiesLastSeenUpdate < BaseMutation
    returns API::V2Internal::Types::ViewerType

    def perform
      current_user&.update!(
        notification_feed_items_unread_count: 0,
        notification_feed_last_seen_at: Time.current,
      )

      current_user
    end
  end
end
