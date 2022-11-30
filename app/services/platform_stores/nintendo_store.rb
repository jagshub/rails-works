# frozen_string_literal: true

module PlatformStores
  class NintendoStore < Store.new(
    enum: 10,
    name: 'Nintendo',
    key: :nintendo,
    os: 'Nintendo Switch',
    matchers: [
      %r{^nintendo\.com/games/detail/\w+}i,
    ],
  )
  end
end
