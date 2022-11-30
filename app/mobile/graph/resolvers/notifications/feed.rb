# frozen_string_literal: true

class Mobile::Graph::Resolvers::Notifications::Feed < Mobile::Graph::Resolvers::BaseResolver
  type Mobile::Graph::Types::Notifications::FeedItemType.connection_type, null: false

  class FeedKind < Mobile::Graph::Types::BaseEnum
    graphql_name 'NotificationsKindEnum'

    value 'my_activity'
    value 'following'
  end

  argument :kind, FeedKind, required: true

  def resolve(kind:)
    user = current_user
    return [] if user.blank?

    scope = Stream::FeedItem.visible.for_user(user).by_priority

    return scope.where(*my_activity_clause) if kind == 'my_activity'

    scope.where.not(*my_activity_clause)
  end

  private

  def my_activity_clause
    post_ids = (current_user.posts.pluck(:id) + current_user.products.pluck(:id)).uniq.map(&:to_s)
    discussion_ids = current_user.discussion_threads.pluck(:id).uniq.map(&:to_s)

    [
      "
        connecting_text = '#{ Stream::FeedItem::MENTIONED_YOU_IN }'
        OR connecting_text = '#{ Stream::FeedItem::COMMENTED_ON_YOUR }'
        OR (verb = 'comment' AND data->'target'->>'type' = 'Post' AND data->'target'->>'id' IN (?))
        OR (verb = 'comment' AND data->'target'->>'type' = 'Discussion::Thread' AND data->'target'->>'id' IN (?))
        OR connecting_text = '#{ Stream::Activities::VoteCreated::CONNECTING_TEXTS['Comment'] }'
        OR connecting_text = '#{ Stream::Activities::VoteCreated::CONNECTING_TEXTS['Recommendation'] }'
        OR (verb = 'upvote' AND data->'target'->>'type' = 'Post' AND data->'target'->>'id' IN (?))
        OR verb = 'post-maker-list'
        OR verb = 'user-follow'
      ",
      post_ids,
      discussion_ids,
      post_ids,
    ]
  end
end
