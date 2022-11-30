# frozen_string_literal: true

module Graph::Types
  class ModerationFlagsStatsType < BaseObject
    graphql_name 'ModerationFlagsStats'

    field :urgent_flagged_comments_count, Int, null: false
    field :urgent_flagged_reviews_count, Int, null: false
    field :urgent_flagged_posts_count, Int, null: false
    field :urgent_flagged_users_count, Int, null: false
    field :urgent_flagged_products_count, Int, null: false
    field :urgent_flagged_team_requests_count, Int, null: false
    field :other_flagged_comments_count, Int, null: false
    field :other_flagged_reviews_count, Int, null: false
    field :other_flagged_posts_count, Int, null: false
    field :other_flagged_users_count, Int, null: false
    field :other_flagged_products_count, Int, null: false
  end
end
