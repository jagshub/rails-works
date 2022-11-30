# frozen_string_literal: true

class Products::Admin::AssociatePostsForm < Admin::BaseForm
  model :product, attributes: %i(post_ids), save: true

  main_model :product, Product

  delegate :posts, to: :product

  attr_reader :suggested_post_ids

  def initialize(product)
    @product = product
  end

  def post_ids=(post_ids)
    Products::SetProductPostIds.call(
      product: product,
      post_ids: post_ids,
      source: :admin,
      reassociate: true,
    )
  end
end
