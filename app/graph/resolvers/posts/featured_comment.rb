# frozen_string_literal: true

class Graph::Resolvers::Posts::FeaturedComment < Graph::Resolvers::Base
  type Graph::Types::CommentType, null: true

  TOP_COMMENTS_COUNT = 1

  def resolve
    return if current_user.blank?
    return if context[:request_info].mobile?

    FriendsCommentsLoader.for(current_user).load(object.id)
  end

  class FriendsCommentsLoader < GraphQL::Batch::Loader
    SQL = <<-SQL
      SELECT *
      FROM (
        SELECT
          comments.*,
          ROW_NUMBER() OVER( PARTITION BY comments.subject_id ORDER BY comments.credible_votes_count) as rank
        FROM comments
          INNER JOIN user_friend_associations ON user_friend_associations.following_user_id = comments.user_id
        WHERE
          comments.subject_type = 'Post'
          AND comments.parent_comment_id IS NULL
          AND comments.trashed_at IS NULL
          AND comments.subject_id IN (:post_ids)
          AND user_friend_associations.followed_by_user_id = :user_id
      ) AS selected_comments
      WHERE
        rank <= :comments_count
    SQL

    def initialize(user)
      @user = user
    end

    def perform(post_ids)
      data = ExecSql
             .call(SQL, user_id: @user.id, post_ids: post_ids, comments_count: TOP_COMMENTS_COUNT)
             .group_by { |comment| comment['subject_id'] }

      post_ids.each do |id|
        comments = (data[id] || []).map { |comment| Comment.new(comment.except('rank')) }

        fulfill(id, comments[0])
      end
    end
  end
end
