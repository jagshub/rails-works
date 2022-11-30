# frozen_string_literal: true

module PlatformStores
  class ShopifyStore < Store.new(
    enum: 25,
    name: 'Shopify',
    key: :shopify,
    os: 'Web',
    matchers: [
      %r{^apps\.shopify\.com/[^?#]+}i,
      %r{^([\w\d-]+)\.myshopify\.com(/[^?#]+)?}i,
    ],
  )
  end
end
