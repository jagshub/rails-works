# frozen_string_literal: true

module PlatformStores
  class NullStore < Store.new(
    enum: nil,
    name: nil,
    key: nil,
    os: nil,
    matchers: [],
  )
  end
end
