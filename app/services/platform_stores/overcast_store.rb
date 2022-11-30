# frozen_string_literal: true

module PlatformStores
  class OvercastStore < Store.new(
    enum: 11,
    key: :overcast,
    name: 'Overcast',
    os: 'Web',
    matchers: [
      %r{^overcast\.fm/\+\w+}i, # overcast.fm/+ID
      %r{^overcast\.fm/[\w-]+/[\w-]+}i, # overcast.fm/DIRECTORY/ID
    ],
  )
  end
end
