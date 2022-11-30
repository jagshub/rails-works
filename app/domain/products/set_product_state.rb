# frozen_string_literal: true

module Products::SetProductState
  extend self

  def call(product)
    # Note(Rahul): We don't use posts_count column here since
    #              it's only counts visible posts
    posts_count = product.posts.count
    return if posts_count == 0

    offline_posts_count = product.posts.merge(Post.no_longer_online).count

    state = posts_count == offline_posts_count ? 'no_longer_online' : 'live'

    product.update!(state: state)
  end

  def mark_as_offline(product)
    product.posts.update_all(product_state: :no_longer_online)

    product.no_longer_online!
  end
end
