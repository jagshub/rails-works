# frozen_string_literal: true

module Products::SetProductPostIds
  extend self

  def call(product:, post_ids:, source: :admin, reassociate: false)
    post_ids = post_ids.map(&:presence).compact.uniq.map { |p_id| Integer(p_id) }

    # Create new associations
    (post_ids - product.post_ids).each do |post_id|
      post = Post.find(post_id)
      Products::MovePost.call(post: post, product: product, source: source)
    end

    # Destroy old associations and unlink reviews
    product.post_associations.each do |association|
      unless association.post_id.in?(post_ids)
        post = association.post
        Products::MovePost.call(post: post, product: nil, source: source, reassociate: reassociate)
      end
    end

    # Sync awards from posts
    Products::RefreshActivityEventsWorker.perform_later(product)
  end
end
