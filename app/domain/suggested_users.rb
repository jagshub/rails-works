# frozen_string_literal: true

module SuggestedUsers
  extend self

  def suggested_users
    User.where(id: suggested_user_ids)
  end

  def suggested_user_ids
    Rails.cache.fetch('suggested_users', expires_in: 7.days) do
      fetch_suggested_user_ids
    end
  end

  def for_user(current_user, count:, last_shown:)
    friend_ids = current_user.blank? ? [] : current_user.friend_ids
    suggested_ids = SuggestedUsers.suggested_user_ids
    ids = suggested_ids - friend_ids - last_shown.map(&:to_i)

    # Note(RO): if there is no last shown users, we just want to show the sorted count,
    # else we randomize if you have already seen some users.
    if last_shown.empty?
      User.where(id: ids).order(follower_count: :desc).limit(count)
    else
      User.where(id: ids.sample(count))
    end
  end

  private

  # Note(RO): This grabs makers that have basic info filled in, featured launch in the past 180 days, have at least 10 followers,
  # and have commented at least 3 times in the past 14 days on posts that are not their own, sorted by follower count.
  SQL = <<-SQL
  WITH makers AS (
    SELECT makers.user_id, makers.post_id
    FROM product_makers makers
    JOIN posts ON makers.user_id = posts.user_id AND posts.featured_at > CURRENT_DATE - INTERVAL '180 day'
    JOIN users ON makers.user_id = users.id AND makers.post_id = posts.id
    WHERE users.follower_count >= 10
    AND (headline IS NOT NULL OR headline NOT IN (''))
    AND (about IS NOT NULL OR about NOT IN (''))
    AND avatar_uploaded_at IS NOT NULL
    AND users.role IN (0,2)
  ), result AS (
    SELECT comments.user_id, COUNT(*) AS comments_count
    FROM comments
    JOIN makers ON comments.user_id = makers.user_id
    WHERE comments.created_at >= CURRENT_DATE - INTERVAL '14 day'
    AND comments.subject_id != makers.post_id
    GROUP BY 1
  )
  SELECT user_id FROM result WHERE comments_count >= 3
  SQL

  def fetch_suggested_user_ids
    ExecSql.call(SQL).map { |row| row['user_id'] }
  end
end
