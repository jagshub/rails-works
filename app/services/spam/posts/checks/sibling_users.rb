# frozen_string_literal: true

module Spam::Posts::Checks::SiblingUsers
  extend self

  PERIOD = 5.minutes
  MIN_CIRCLE_SIZE = 3
  MIN_COMMON_VOTES = 3
  VOTING_PERIOD = 5.minutes
  MAX_USER_CREATION_PERIOD = 10.minutes
  MIN_SPAMMER_COMMON_VOTES = 5
  MIN_SPAMMER_CIRCLE_SIZE = 4

  QUERY = "
    WITH latest_users_voted AS (
      SELECT
        votes.subject_id AS post_id,
        users.id AS user_id,
        users.created_at AS user_created_at
      FROM votes INNER JOIN users ON users.id = votes.user_id
      WHERE
        votes.created_at >= :votes_from_datetime
        AND votes.created_at <= :votes_to_datetime
        AND votes.subject_type = 'Post'
        AND users.role NOT IN (:ignored_user_roles)
    ),
    users_with_similar_votes AS (
      SELECT
        v1.user_id as user_id_1,
        v2.user_id as user_id_2,
        COUNT(*) AS total_votes
        FROM latest_users_voted AS v1 INNER JOIN latest_users_voted AS v2 ON
          v2.post_id = v1.post_id
          AND ABS(EXTRACT(EPOCH FROM (v1.user_created_at - v2.user_created_at))) <= :max_user_creation_period
        GROUP BY 1, 2
        HAVING COUNT(*) >= :min_common_votes
    ),
    spam_circles AS (
      SELECT
        COUNT( DISTINCT u.user_id_2 ) AS circle_size,
        AVG(u.total_votes) AS avg_votes,
        ARRAY_AGG( DISTINCT u.user_id_2 ORDER BY u.user_id_2 ) AS circle
      FROM users_with_similar_votes AS u
      GROUP BY
        u.user_id_1
      HAVING
        COUNT( DISTINCT u.user_id_2 ) >= :min_circle_size
    )

    SELECT * FROM spam_circles GROUP BY circle, circle_size, avg_votes;
  "

  def run(at: Time.zone.now)
    ExecSql.call(
      QUERY,
      votes_from_datetime: at - VOTING_PERIOD,
      votes_to_datetime: at,
      min_common_votes: MIN_COMMON_VOTES,
      max_user_creation_period: MAX_USER_CREATION_PERIOD.to_i,
      min_circle_size: MIN_CIRCLE_SIZE,
      ignored_user_roles: %i(can_post admin).map { |role| User.roles[role] },
    ).flat_map do |details|
      details['circle'].delete('{}').split(',').map do |user_id|
        {
          id: user_id.to_i,
          more_information: { circle: details['circle'], circle_size: details['circle_size'], start_time: at - VOTING_PERIOD, end_time: at, avg_votes: details['avg_votes'] },
          actions: get_action(details),
        }
      end
    end
  end

  private

  def get_action(details)
    if details['avg_votes'].to_i >= MIN_SPAMMER_COMMON_VOTES || details['circle_size'].to_i >= MIN_SPAMMER_CIRCLE_SIZE
      %w(update_role mark_votes)
    else
      %w(mark_votes)
    end
  end
end
