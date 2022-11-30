# frozen_string_literal: true

module Sharing::ImageUrl::ProductRequest
  extend self

  SOCIAL_IMAGES = %w(
    product-request-1.png
    product-request-2.png
    product-request-3.png
    product-request-4.png
    product-request-5.png
    product-request-6.png
    product-request-7.png
    product-request-8.png
    product-request-9.png
    product-request-10.png
    product-request-11.png
  ).freeze

  POPULAR_SOCIAL_IMAGES = %w(
    product-request-1-hot.png
    product-request-2-hot.png
    product-request-3-hot.png
    product-request-4-hot.png
    product-request-5-hot.png
    product-request-7-hot.png
    product-request-8-hot.png
    product-request-9-hot.png
  ).freeze

  def call(product_request)
    images = product_request.recommended_products_count < 3 ? SOCIAL_IMAGES : POPULAR_SOCIAL_IMAGES
    image_filename = images[product_request.id % images.length]

    S3Helper.image_url("social/#{ image_filename }")
  end
end
