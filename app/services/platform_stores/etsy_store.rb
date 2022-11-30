# frozen_string_literal: true

module PlatformStores
  class EtsyStore < Store.new(
    enum: 30,
    name: 'Etsy',
    key: :etsy,
    os: 'Web',
    matchers: [
      %r{^etsy.com/listing/\d+/[\w\d-]+}i,
      %r{^etsy.com/shop/[\w\d-]+}i,
    ],
  )
  end
end
