# frozen_string_literal: true

module Products::MovePost
  extend self

  def call(post:, product:, source: :admin, reassociate: false)
    Products::PostAssociation.transaction do
      old_product = post.new_product

      if product.nil? && reassociate
        product = Products::Find.by_url(post.primary_link.url, exact: true)
        product ||= Products::Create.for_post(post.reload)
      end

      if product.nil?
        post.product_association&.destroy
        post.reviews.update_all(product_id: nil)
      elsif product != old_product
        post.product_association&.destroy

        Products::PostAssociation.create!(
          post: post,
          product: product,
          kind: :version,
          source: source,
        )

        post.reviews.update_all(product_id: product.id)
      end

      if product
        product.refresh_posts_count
        product.refresh_review_counts
        product.update_reviews_rating
        product.update_vote_counts
        product.update_post_timestamps
      end

      if old_product
        old_product.refresh_posts_count
        old_product.refresh_review_counts
        old_product.update_reviews_rating
        old_product.update_vote_counts
        old_product.update_post_timestamps
      end
    end
  end
end
