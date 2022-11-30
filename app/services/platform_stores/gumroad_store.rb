# frozen_string_literal: true

module PlatformStores
  class GumroadStore < Store.new(
    enum: 31,
    name: 'Gumroad',
    key: :gumroad,
    os: 'Web',
    matchers: [
      %r{^gumroad\.com/l/[\w\d-]+}i,
      %r{^[\w\d-]+\.gumroad\.com/l/[\w\d-]+}i,
      /^[\w\d-]+\.gumroad\.com/,
      %r{^gum\.co/[^/]+}i,
    ],
  )
  end
end
