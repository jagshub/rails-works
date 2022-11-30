# frozen_string_literal: true

module PlatformStores
  class LoomStore < Store.new(
    enum: 24,
    name: 'Loom',
    key: :loom,
    os: 'Web',
    matchers: [
      %r{^loom\.com/share/[^?#]+}i,
      %r{^useloom\.com/share/[^?#]+}i,
    ],
  )
  end
end
