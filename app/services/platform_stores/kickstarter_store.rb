# frozen_string_literal: true

module PlatformStores
  class KickstarterStore < Store.new(
    enum: 16,
    name: 'Kickstarter',
    key: :kickstarter,
    os: 'Web',
    matchers: [
      %r{^kickstarter.com/projects(/[\w\d-]+/[\w\d-]+)}i,
    ],
  )
  end
end
