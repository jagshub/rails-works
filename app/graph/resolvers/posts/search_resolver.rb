# frozen_string_literal: true

module Graph::Resolvers
  class Posts::SearchResolver < BaseSearch
    scope { Post.visible.order(credible_votes_count: :desc) }

    type Graph::Types::PostType.connection_type, null: false

    option :query, type: String, with: :apply_query
    option :featured, type: Boolean, default_value: true, with: :apply_featured
    option :year, type: Integer, with: :apply_year

    def apply_featured(scope, value)
      return scope unless value

      scope.featured
    end

    # NOTE(DZ): This year filter uses scheduled at. It may be better to use
    # featured_at in some edge cases, but for most part the feature date should
    # not be too far from scheduled at
    def apply_year(scope, value)
      return scope if value.blank?

      scope.where("EXTRACT(YEAR from scheduled_at) = '?'", value)
    end

    def apply_query(scope, value)
      scope.where_like_slow(:name, value)
    end
  end
end
