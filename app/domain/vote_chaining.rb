# frozen_string_literal: true

module VoteChaining
  extend self

  # NOTE(naman): caching ids in rails for very short period
  # because first the count is fetched and then in the subsequent
  # request the post items
  def posts(post:, current_user: nil)
    cached_posts = get_posts_from_cache(post, current_user)
    return cached_posts if cached_posts.present?
    return Post.none if post.new_product.nil?

    scope = Post.alive.visible.by_credible_votes
      .joins(:new_product)
      .joins(<<-SQL).
        INNER JOIN product_associations
                on product_associations.associated_product_id = product_post_associations.product_id
      SQL
      merge(Products::ProductAssociation.where(product: post.new_product))
      .order(
        Arel.sql(
          "array_position(ARRAY['related', 'alternative', 'addon']::varchar[], product_associations.relationship)",
        ),
      )

    if current_user.present?
      upvoted = Post.joins(:votes).where(votes: { user_id: current_user.id })
      scope = scope.where.not(id: upvoted)
    end

    set_posts_to_cache(post, scope.limit(3), current_user)
  end

  def count(post:, current_user: nil)
    posts(post: post, current_user: current_user).length
  end

  private

  def get_posts_from_cache(post, current_user = nil)
    ids = Rails.cache.read(cache_key(post, current_user))
    return Post.where(id: ids).all if ids.present? && ids.length >= 3

    []
  end

  def set_posts_to_cache(post, posts, current_user = nil)
    Rails.cache.write(cache_key(post, current_user), posts.pluck(:id), expires_in: current_user.present? ? 10.seconds : 1.day)
    posts
  end

  def cache_key(post, current_user = nil)
    "graph_vote_chaining_post_ids_on_post_#{ post.id }_for_user_#{ current_user.present? ? current_user.id : 'logged_out' }"
  end
end
