# frozen_string_literal: true

module PlatformStores
  class SteamStore < Store.new(
    enum: 4,
    name: 'Steam',
    key: :steam,
    os: nil,
    matchers: [
      %r{^store\.steampowered\.com/app/\d+}i,
      %r{^steamcommunity\.com\/app/\d+}i,
    ],
  )
  end
end
