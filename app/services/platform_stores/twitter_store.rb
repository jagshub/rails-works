# frozen_string_literal: true

module PlatformStores
  class TwitterStore < Store.new(
    enum: 38,
    name: 'Twitter',
    key: :twitter,
    os: 'Web',
    matchers: [
      %r{^(m|mobile|www)\.twitter\.com/[/\w\d-]+}i,
      %r{^twitter\.com/[/\w\d-]+}i,
    ],
  )
  end
end
