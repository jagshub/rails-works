# frozen_string_literal: true

module Karma::Users
  extend self

  def ids_to_update_since(time)
    user_ids = Set.new

    user_ids += Comment.where('updated_at >= ?', time).pluck(:user_id)
    user_ids += Discussion::Thread.where('updated_at >= ?', time).pluck(:user_id)
    user_ids += Goal.where('updated_at >= ?', time).pluck(:user_id)

    Post
      .includes(:product_makers)
      .where('posts.updated_at >= ?', time)
      .find_each { |post| user_ids += [post.user_id] + post.product_makers.pluck(:user_id) }

    user_ids.to_a
  end

  def find_each_to_populate
    User.where(karma_points_updated_at: nil).find_each { |user| yield(user) }
  end
end
