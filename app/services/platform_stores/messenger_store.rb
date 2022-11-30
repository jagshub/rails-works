# frozen_string_literal: true

module PlatformStores
  class MessengerStore < Store.new(
    enum: 19,
    key: :messenger,
    name: 'Messenger',
    os: 'Web',
    matchers: [
      %r{^messenger.com/t(/[\w\d-]+)}i,
    ],
  )
  end
end
