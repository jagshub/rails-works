# frozen_string_literal: true

module Karma::Points
  extend self

  def for(user)
    (from_comments_for(user) +
    from_discussions_for(user) +
    from_products_hunted_for(user) +
    from_products_made_for(user) +
    from_deprecated_features(user)
    ).floor
  end

  def update_for(user)
    user.karma_points = self.for(user)
    user.karma_points_updated_at = Time.current
    user.save!
  end

  private

  def from_comments_for(user)
    Comment.not_hidden.where(user_id: user.id).sum(:credible_votes_count) || 0
  end

  def from_discussions_for(user)
    0.1 * (Discussion::Thread.not_trashed.not_hidden.where(user_id: user.id).sum(:credible_votes_count) || 0)
  end

  def from_products_hunted_for(user)
    0.1 * (Post.not_trashed.where(user_id: user.id).sum(:credible_votes_count) || 0)
  end

  def from_products_made_for(user)
    # NOTE(naman): if the user is both hunter and maker of the post, we don't consider points for the maker
    0.1 * (Post.not_trashed.joins(:product_makers).where('posts.user_id != product_makers.user_id AND product_makers.user_id = ?', user.id).sum(:credible_votes_count) || 0)
  end

  def from_deprecated_features(user)
    user.deleted_karma_logs.sum(:karma_value) || 0
  end
end
