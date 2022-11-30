# frozen_string_literal: true

module PlatformStores
  class FigmaStore < Store.new(
    enum: 32,
    name: 'Figma',
    key: :figma,
    os: 'Web',
    matchers: [
      %r{figma.com/(community|c)/[^/]+/\d+(/[^?]+)?}i,
      %r{figma.com/(proto|file)/[\d\w]+(/[^?]+)?}i,
      %r{figma.com/@[^/]+}i,
    ],
  )
  end
end
