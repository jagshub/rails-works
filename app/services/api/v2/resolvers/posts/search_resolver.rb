# frozen_string_literal: true

module API::V2::Resolvers
  class Posts::SearchResolver < BaseSearchResolver
    # NOTE(dhruvparmar372): Type needs to be explicitly set to connection_type
    # here because Member::BuildType.to_type_name fails here https://github.com/rmosolgo/graphql-ruby/blob/545a3acf885f97489c154eb63d7975228fa80a99/lib/graphql/schema/field.rb#L114
    # for some reason
    type ::API::V2::Types::PostType.connection_type, null: false

    scope { Post.visible }

    option :featured, type: GraphQL::Types::Boolean, description: 'Select Posts that have been featured or not featured depending on given value.', with: :apply_featured
    option :posted_before, type: API::V2::Types::DateTimeType, description: 'Select Posts which were posted before the given date and time.', with: :apply_posted_before
    option :posted_after, type: API::V2::Types::DateTimeType, description: 'Select Posts which were posted after the given date and time.', with: :apply_posted_after
    # NOTE(dhruvparmar372): Using simple String raises expected 'topic' to be
    # valid input type (Scalar or InputObject) error. Probably an issue with
    # scoping, fallback to full scope for now
    option :topic, type: GraphQL::Types::String, description: 'Select Posts that have the given slug as one of their topics.', with: :apply_topic_filter
    option :order, type: API::V2::Types::PostsOrderType, description: 'Define order for the Posts.', default: 'RANKING'
    option :twitter_url, type: GraphQL::Types::String, description: 'Select Posts that have the given twitter url.', with: :apply_twitter_url_filter
    option :url, type: GraphQL::Types::String, description: 'Select Posts that have the given url.', with: :apply_url_filter

    private

    def apply_featured(scope, value)
      return if value.blank? || !value

      scope.featured
    end

    def apply_posted_after(scope, value)
      return if value.blank?

      scope.where(Post.arel_table[posted_at_column].gteq(value))
    end

    def apply_posted_before(scope, value)
      return if value.blank?

      scope.where(Post.arel_table[posted_at_column].lteq(value))
    end

    def apply_topic_filter(scope, value)
      return if value.blank?

      topic = Topic.friendly.find value
      scope.in_topic topic
    rescue ActiveRecord::RecordNotFound
      Post.none
    end

    def apply_order_with_votes(scope)
      scope.by_votes
    end

    def apply_order_with_featured_at(scope)
      scope.by_featured_at
    end

    def apply_order_with_ranking(scope)
      scope
        .select("posts.*, (#{ ::Posts::Ranking.algorithm_in_sql }) as rank")
        .order(
          Arel.sql('DATE(featured_at) DESC NULLS LAST'),
          rank: :desc,
        )
    end

    def apply_order_with_newest(scope)
      scope.by_created_at
    end

    def posted_at_column
      featured ? :featured_at : :scheduled_at
    end

    def apply_twitter_url_filter(scope, value)
      scope.joins(:new_product).where(products: { twitter_url: value })
    end

    def apply_url_filter(scope, value)
      scope.having_url(value)
    end
  end
end
