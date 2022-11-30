# frozen_string_literal: true

module PlatformStores
  class NotionStore < Store.new(
    enum: 23,
    name: 'Notion',
    key: :notion,
    os: 'Web',
    matchers: [
      %r{^notion\.so/.*-\w{32}}i,
    ],
  )
  end
end
