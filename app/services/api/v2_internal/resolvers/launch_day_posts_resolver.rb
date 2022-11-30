# frozen_string_literal: true

class API::V2Internal::Resolvers::LaunchDayPostsResolver < API::V2Internal::Resolvers::BaseResolver
  type [API::V2Internal::Types::PostType], null: false

  def resolve
    user = current_user
    return [] if user.blank?

    posts = Post.where('scheduled_at >= ? AND user_id = ?', 1.day.ago, user.id)
    posts += ProductMaker.joins(:post).where('posts.scheduled_at >= ? AND product_makers.user_id = ?', 1.day.ago, user.id).map(&:post)
    posts.uniq
  end
end
