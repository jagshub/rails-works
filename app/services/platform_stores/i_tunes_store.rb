# frozen_string_literal: true

module PlatformStores
  class ITunesStore < Store.new(
    enum: 15,
    name: 'iTunes',
    key: :itunes,
    os: 'Web',
    matchers: [
      %r{itunes\.apple\.com/\w{2,4}/podcast/[\w-]+/id\d+}i, # itunes.apple.com/COUNTRY/podcasts/SHOW/id0001?META
    ],
  )
  end
end
