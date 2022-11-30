# frozen_string_literal: true

module PlatformStores
  class PodcastsStore < Store.new(
    enum: 22,
    name: 'Podcasts',
    key: :podcasts,
    os: 'Web',
    matchers: [
      %r{^mypodnotes\.com/post(/\d+/[\w\d-]+)}i,
      %r{^soundcloud\.com/(?!go)([\w\d-]+)}i,
      %r{^podcasts\.apple\.com/([/\w\d-]+)/(id\d+)}i,
    ],
  )
  end
end
