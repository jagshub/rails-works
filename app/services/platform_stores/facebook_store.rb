# frozen_string_literal: true

module PlatformStores
  class FacebookStore < Store.new(
    enum: 26,
    name: 'Facebook',
    key: :facebook,
    os: 'Web',
    matchers: [
      %r{^(apps|developers|business|web|m|newsroom|about|npe)\.(facebook|fb)\.com/[/\w\d-]+}i,
      %r{^facebook\.com/[/\w\d-]+}i,
      %r{^fb\.com/[/\w\d-]+}i,
    ],
  )
  end
end
