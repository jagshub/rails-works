# frozen_string_literal: true

module PlatformStores
  class StitcherStore < Store.new(
    enum: 13,
    key: :stitcher,
    name: 'Stitcher',
    os: nil,
    matchers: [
      %r{^stitcher\.com/[\w-]+/[\w-]+}i, # www.stitcher.com/TYPE/SLUG
      %r{^stitcher\.com/s\?eid=\d+}i,    # www.stitcher.com/s?eid=ID
    ],
  )
  end
end
