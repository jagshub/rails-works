# frozen_string_literal: true

class Graph::Resolvers::Moderation::FlagsStatsResolver < Graph::Resolvers::Base
  type Graph::Types::ModerationFlagsStatsType, null: true

  LAYOUT_SQL = <<-SQL.squish
    SELECT
      count(*),
      CASE
        WHEN reason IN ( 'harmful', 'spam' ) THEN 'urgent'
        ELSE 'other'
      END as filter,
      REPLACE(subject_type, '::', '_') as subject
    FROM flags
    WHERE status = 'unresolved'
    GROUP BY
      CASE
        WHEN reason IN ( 'harmful', 'spam' ) THEN 'urgent'
        ELSE 'other'
      END,
      subject_type
  SQL

  DEFAULT_FLAG_STATS = {
    'urgent_flagged_comments_count' => 0,
    'urgent_flagged_reviews_count' => 0,
    'urgent_flagged_posts_count' => 0,
    'urgent_flagged_users_count' => 0,
    'urgent_flagged_products_count' => 0,
    'urgent_flagged_team_requests_count' => 0,
    'other_flagged_comments_count' => 0,
    'other_flagged_reviews_count' => 0,
    'other_flagged_posts_count' => 0,
    'other_flagged_users_count' => 0,
    'other_flagged_products_count' => 0,
  }.freeze

  def resolve
    return DEFAULT_FLAG_STATS unless current_user&.admin?

    results = execute_and_get_result_hash

    DEFAULT_FLAG_STATS.merge(
      results.select { |k, _v| DEFAULT_FLAG_STATS.key?(k) },
    )
  end

  private

  def execute_and_get_result_hash
    ExecSql.call(LAYOUT_SQL).map do |row|
      key = "#{ row['filter'] }_flagged_#{ row['subject'].downcase }s_count"
      [key, row['count']]
    end.to_h
  end
end
