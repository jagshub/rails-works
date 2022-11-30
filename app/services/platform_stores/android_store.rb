# frozen_string_literal: true

module PlatformStores
  class AndroidStore < Store.new(
    enum: 2,
    name: 'Play Store',
    key: :android,
    os: 'Android',
    matchers: [
      %r{^play\.google\.com/store/apps/details\?id=[\w.]+}i,
    ],
  )
  end
end
