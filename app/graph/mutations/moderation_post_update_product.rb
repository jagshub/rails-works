# frozen_string_literal: true

module Graph::Mutations
  class ModerationPostUpdateProduct < BaseMutation
    argument_record :post, Post, authorize: :update
    argument_record :product, Product, authorize: :moderate, required: false
    argument :create_new, Boolean, required: false

    returns Graph::Types::PostType

    def perform(post:, product: nil, create_new: false)
      old_product = post.new_product

      if product.blank? && create_new
        Products::Create.for_post(post, product_source: :moderation)
      else
        Products::MovePost.call(post: post, product: product, source: :moderation)
      end

      post.reload

      Products::RefreshActivityEvents.new(old_product).call if old_product
      Products::RefreshActivityEvents.new(post.new_product).call if post.new_product

      post
    end
  end
end
