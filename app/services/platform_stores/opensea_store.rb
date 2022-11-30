# frozen_string_literal: true

module PlatformStores
  class OpenseaStore < Store.new(
    enum: 34,
    name: 'Opensea',
    key: :opensea,
    os: 'Web',
    matchers: [
      %r{^opensea.io/collection/[\w\d-]+}i,
      %r{^opensea.io/assets/matic/0x.*}i,
      %r{^opensea.io/[\w\d-]+}i,
    ],
  )
  end
end
