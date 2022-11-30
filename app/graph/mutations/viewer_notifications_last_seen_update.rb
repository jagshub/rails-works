# frozen_string_literal: true

module Graph::Mutations
  class ViewerNotificationsLastSeenUpdate < BaseMutation
    returns Graph::Types::ViewerType

    require_current_user

    def perform
      current_user.update! notification_feed_last_seen_at: Time.current, notification_feed_items_unread_count: 0
      current_user
    end
  end
end
