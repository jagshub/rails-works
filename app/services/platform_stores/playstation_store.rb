# frozen_string_literal: true

module PlatformStores
  class PlaystationStore < Store.new(
    enum: 6,
    name: 'Playstation',
    key: :playstation,
    os: 'Playstation',
    matchers: [
      %r{^playstation\.com/en-us/[/\w\d-]+}i,
      %r{^store\.playstation\.com/#!/en-us/[/\w\d-]+/}i,
    ],
  )
  end
end
