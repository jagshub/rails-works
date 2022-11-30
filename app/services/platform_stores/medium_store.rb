# frozen_string_literal: true

module PlatformStores
  class MediumStore < Store.new(
    enum: 27,
    name: 'Medium',
    key: :medium,
    os: 'Web',
    matchers: [
      %r{^medium.com/@?[\w\d-]+(/[\w\d-]+)?}i,
      %r{^[\w\d-]+\.medium.com/}i,
    ],
  )
  end
end
