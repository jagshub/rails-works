# frozen_string_literal: true

class Graph::Resolvers::Topics::FeedResolver < Graph::Resolvers::BaseSearch
  scope do
    scope = Post.visible.featured.by_featured_at.by_credible_votes
    scope = scope.group('posts.id').joins(:post_topic_associations)

    if current_user.nil?
      scope
    else
      topic_ids = Topic
                  .joins(:subscriptions)
                  .where('subscriptions.subscriber_id' => current_user.subscriber.id)
                  .pluck(:id)

      scope.where('post_topic_associations.topic_id' => topic_ids)
    end
  end

  option :include_topic_ids, type: [GraphQL::Types::ID], with: :include_topics

  private

  def include_topics(scope, ids)
    scope.where('post_topic_associations.topic_id IN (?)', ids)
  end
end
