# frozen_string_literal: true

module PlatformStores
  class SlackStore < Store.new(
    enum: 18,
    key: :slack,
    name: 'Slack',
    os: nil,
    matchers: [
      %r{^slack.com/apps(/[\w\d-]+)}i,
      %r{^([\w\d-]+).slack.com/apps(/[\w\d-]+)}i,
    ],
  )
  end
end
