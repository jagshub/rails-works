# frozen_string_literal: true

class Graph::Resolvers::Notifications::Feed < Graph::Resolvers::Base
  type Graph::Types::Notifications::FeedItemType.connection_type, null: false

  argument :mentions_only, Boolean, required: false

  def resolve(mentions_only:)
    user = current_user
    return [] if user.blank?

    scope = Stream::FeedItem.visible.for_user(user).by_priority
    scope = scope.for_connecting_text(Stream::FeedItem::MENTIONED_YOU_IN) if mentions_only == true
    scope
  end
end
