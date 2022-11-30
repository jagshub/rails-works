# frozen_string_literal: true

module Spam::Posts::Checks::SimilarVotes
  extend self

  PERIOD = 30.days
  MIN_VOTES_COUNT = 5
  MIN_VOTES_COUNT_FOR_ACTION = 10

  def run(posts: nil)
    post_ids = posts.present? ? posts.pluck(:id) : nil

    ExecSql.call(
      get_query(post_ids: post_ids),
      post_ids: post_ids,
      created_after: Time.zone.now - PERIOD,
      similar_votes_min_count: MIN_VOTES_COUNT,
      user_roles: (%i(user).map { |role| User.roles[role] }),
    ).map do |user|
      {
        id: user['id'],
        more_information: { circle: user['circle'], circle_size: user['circle_size'], min_common_votes_count: user['min_common_votes_count'] },
        actions: get_actions(user),
      }
    end
  end

  def get_query(post_ids: nil)
    spam_users = nil
    if post_ids.present?
      spam_users = "spam_users AS (
        SELECT users.*
        FROM users INNER JOIN votes ON users.id = votes.user_id
        WHERE
          votes.subject_type= 'Post'
          AND votes.subject_id IN (:post_ids)
          AND users.role IN (:user_roles)
        GROUP BY users.id
      ),"
    end

    "WITH #{ spam_users }
        spam_votes AS (
        SELECT
          ROW_NUMBER() OVER(PARTITION BY users.id ORDER BY votes.created_at DESC) AS vote_rank,
          users.id AS user_id,
          users.username AS username,
          votes.subject_id AS post_id
        FROM #{ spam_users && 'spam_users AS' } users INNER JOIN votes ON users.id = votes.user_id
        WHERE
        votes.created_at >= :created_after
        AND votes.subject_type = 'Post'
        AND users.role IN (:user_roles)
      ), similar_votes_pairs AS (
        SELECT
          COUNT(*) as common_votes_count,
          sv1.user_id AS user_id,
          sv2.username AS username
        FROM spam_votes AS sv1 INNER JOIN spam_votes AS sv2
          ON sv1.vote_rank = sv2.vote_rank AND sv1.post_id = sv2.post_id
        GROUP BY sv1.user_id, sv2.username
        HAVING
          COUNT(*) >= :similar_votes_min_count
          AND MAX(sv1.vote_rank) - MIN(sv1.vote_rank) + 1 = COUNT(*)

      ), spam_circles AS (
        SELECT
          COUNT(*) AS circle_size,
          user_id,
          ARRAY_AGG(username ORDER BY username) AS circle,
          MIN(common_votes_count) as min_common_votes_count
        FROM similar_votes_pairs
        GROUP BY user_id
        HAVING
          COUNT(*) > 1
          AND MIN(common_votes_count) >= :similar_votes_min_count
      )

      SELECT user_id AS id, circle, circle_size, min_common_votes_count FROM spam_circles
    "
  end

  def get_actions(details)
    if details['min_common_votes_count'] >= MIN_VOTES_COUNT_FOR_ACTION && details['circle_size'] > 4
      %w(update_role mark_votes)
    elsif details['min_common_votes_count'] >= MIN_VOTES_COUNT && details['circle_size'] > 7
      %w(update_role mark_votes)
    else
      []
    end
  end
end
