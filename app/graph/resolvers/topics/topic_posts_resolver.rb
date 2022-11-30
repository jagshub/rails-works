# frozen_string_literal: true

class Graph::Resolvers::Topics::TopicPostsResolver < Graph::Resolvers::BaseSearch
  ORDERS = %w(trending by-date most-commented most-upvoted).freeze

  scope { object.posts.featured.alive }

  option :query, type: String, with: :by_query
  option :subtopic, type: GraphQL::Types::ID, with: :by_subtopic
  option :order, type: String, with: :by_order, default: 'trending'

  private

  def by_query(scope, value)
    return if value.blank?

    scope.where '(lower(name) LIKE :query OR lower(tagline) LIKE :query)', query: LikeMatch.by_words(query)
  end

  def by_subtopic(scope, value)
    return if value.blank?
    return unless Topic.exists?(value)

    scope.joins('INNER JOIN post_topic_associations sub_topics ON sub_topics.post_id = posts.id').where('sub_topics.topic_id' => value)
  end

  def by_order(scope, value)
    value ||= 'trending'

    order = ORDERS.detect { |val| value.include?(val) }

    case clear_order_value(order)
    when 'trending' then ::Posts::Ranking.apply(scope.featured)
    when 'by-date' then scope.visible.by_created_at
    when 'most-commented' then scope.visible.by_comments_count
    when 'most-upvoted' then scope.visible.by_credible_votes
    else
      raise ArgumentError, "#{ value } is invalid type." unless Rails.env['production']

      scope
    end
  end

  def clear_order_value(value)
    value.to_s.gsub(/'.*/, '')
  end
end
