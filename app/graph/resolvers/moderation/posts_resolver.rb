# frozen_string_literal: true

class Graph::Resolvers::Moderation::PostsResolver < Graph::Resolvers::BaseSearch
  scope { Post.not_trashed }

  type Graph::Types::PostType.connection_type, null: false

  class KindEnum < Graph::Types::BaseEnum
    graphql_name 'ModerationPostResolverKind'

    value 'newest', 'Newest post today'
    value 'edited', 'Moderated posts that have been edited by an user'
    value 'unfeatured_trending', 'Unfeatured trending posts today with 15+ upvotes'
    value 'unfeatured', 'All unfeatured posts from the past day'
    value 'high_non_credible', 'Featured posts with 30% or more non-credible upvotes'
  end

  option :kind, type: KindEnum, default: 'newest'
  option :order, type: Graph::Types::SortOrderType

  private

  def apply_kind_with_newest(scope)
    # NOTE(naman):
    # newest section should show:
    # - new posts created which are not reviewed yet
    # - old posts which were created before and reviewed
    #   but scheduled for launch today having content
    #   updated by the user after last review.
    yesterday = Time.zone.yesterday.end_of_day.utc
    tomorrow = Time.zone.tomorrow.beginning_of_day.utc

    scope
      .joins(<<~SQL.squish)
        INNER JOIN (
          SELECT posts.id, MAX(moderation_logs.created_at) AS last_reviewed_at
          FROM posts LEFT OUTER JOIN moderation_logs ON
              moderation_logs.reference_id = posts.id
              AND moderation_logs.reference_type = 'Post'
              AND moderation_logs.message = '#{ ModerationLog::REVIEWED_MESSAGE }'
          WHERE
            posts.trashed_at IS NULL AND (
              posts.created_at >= '#{ yesterday }' OR (
                posts.scheduled_at >= '#{ yesterday }'
                AND posts.scheduled_at <= '#{ tomorrow }'
              )
            )
          GROUP BY posts.id
        ) AS post_moderations ON post_moderations.id = posts.id
      SQL
      .where(<<~SQL.squish)
        (
          posts.created_at >= '#{ yesterday }'
          AND post_moderations.last_reviewed_at IS NULL
        ) OR (
          post_moderations.last_reviewed_at IS NOT NULL
          AND posts.scheduled_at >= '#{ yesterday }'
          AND posts.scheduled_at <= '#{ tomorrow }'
          AND posts.user_edited_at > post_moderations.last_reviewed_at
        )
      SQL
  end

  def apply_kind_with_edited(scope)
    cmp =
      ModerationLog.arel_table[:created_at].lt(Post.arel_table[:user_edited_at])

    scope
      .distinct
      .left_outer_joins(:moderation_logs)
      .where_date_gteq(:created_at, Time.zone.yesterday)
      .where(cmp)
  end

  def apply_kind_with_unfeatured_trending(scope)
    scope
      .where_date_gteq(:created_at, Time.zone.yesterday)
      .where('featured_at IS NULL AND credible_votes_count >= 15')
  end

  def apply_kind_with_unfeatured(scope)
    scope
      .where_date_between(:scheduled_at, Time.zone.yesterday, Time.zone.today)
      .where('featured_at IS NULL')
  end

  def apply_kind_with_high_non_credible(scope)
    scope
      .where_date_gteq(:created_at, Time.zone.yesterday)
      .where('votes_count >= 15')
      .where('featured_at IS NOT NULL AND (((votes_count - credible_votes_count) * 100) / votes_count) >= 30')
  end

  def apply_order_with_asc(scope)
    scope.order(updated_at: :asc)
  end

  def apply_order_with_desc(scope)
    scope.order(updated_at: :desc)
  end
end
