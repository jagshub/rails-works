# frozen_string_literal: true

module Oembed::Endpoints::ProductsEndpoint
  extend self
  include Oembed::Endpoint

  MATCHERS = {
    %r{\A(?<protocol>https{0,1}:\/\/){0,1}(?<domain>(www\.){0,1}(producthunt\.com|producthunt\.org))\/(?<category>tech|games|books|podcasts|posts|products)\/(?<id>.+)\Z}i => :products,
  }.freeze

  PRODUCTS_SIZE_RATIO = (500.0 / 405.0)
  MINIMUM_SIZE = 280
  MAXIMUM_SIZE = 500

  def products(match, maxheight: nil, maxwidth: nil)
    product = Product.visible.friendly.find(match[:id])

    maxwidth = MAXIMUM_SIZE if maxwidth.nil? || maxwidth > MAXIMUM_SIZE
    maxheight = MAXIMUM_SIZE if maxheight.nil? || maxheight > MAXIMUM_SIZE
    width, height = compute_max_size(MINIMUM_SIZE, MINIMUM_SIZE, maxwidth.to_i, maxheight.to_i, PRODUCTS_SIZE_RATIO)
    thumbnail_url = product.thumbnail_url(width: width, height: height, fit: 'max')
    iframe_url = "https://cards.producthunt.com/cards/products/#{ product.id }"
    {
      version: '1.0',
      title: product.name,
      type: 'rich',
      width: width,
      height: height,
      html: %(<iframe style="border: none;" src="#{ iframe_url }" width="#{ width }" height="#{ height }" frameborder="0" scrolling="no" allowfullscreen></iframe>),
      thumbnail_url: thumbnail_url,
      thumbnail_width: width,
      thumbnail_height: height,
      provider_name: 'Product Hunt',
      provider_url: 'https://www.producthunt.com',
    }
  rescue ActiveRecord::RecordNotFound
    nil
  end
end
