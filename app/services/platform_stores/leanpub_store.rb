# frozen_string_literal: true

module PlatformStores
  class LeanpubStore < Store.new(
    enum: 37,
    name: 'Leanpub',
    key: :leanpub,
    os: 'Web',
    matchers: [
      %r{^leanpub.com/[^?]+},
    ],
  )
  end
end
