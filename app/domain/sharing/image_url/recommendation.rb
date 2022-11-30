# frozen_string_literal: true

module Sharing::ImageUrl::Recommendation
  extend self

  def call(recommendation)
    product = recommendation.recommended_product.product

    Sharing::ImageUrl::Product.call product
  end
end
