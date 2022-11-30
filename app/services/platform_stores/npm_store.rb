# frozen_string_literal: true

module PlatformStores
  class NpmStore < Store.new(
    enum: 28,
    name: 'Npm',
    key: :npm,
    os: 'Web',
    matchers: [
      %r{^npmjs.com/package/[\w\d-]+}i,
    ],
  )
  end
end
