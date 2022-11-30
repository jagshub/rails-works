# frozen_string_literal: true

class API::V2Internal::Resolvers::ActivityFeedResolver < Graph::Resolvers::Base
  type API::V2Internal::Types::ActivityItemType, null: false

  SUPPORTED_TYPES = ['User', 'Post', 'Comment'].freeze

  def resolve
    return [] if current_user.blank?

    Stream::FeedItem.visible.for_user(current_user).by_priority.preload(:target).where(target_type: SUPPORTED_TYPES)
  end
end
