# frozen_string_literal: true

module PlatformStores
  class TuneInStore < Store.new(
    enum: 12,
    key: :tune_in,
    name: 'TuneIn',
    os: nil,
    matchers: [
      %r{^tunein\.com/\w+/[\w-]+}i, # CATEGORY/SLUG-ID
      %r{^tun\.in/[\w-]+}i,
    ],
  )
  end
end
