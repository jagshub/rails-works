# frozen_string_literal: true

module PlatformStores
  class VisualStudioStore < Store.new(
    enum: 20,
    name: 'Visual Studio Marketplace',
    key: :visual_studio,
    os: nil,
    matchers: [
      %r{^marketplace\.visualstudio\.com/items\?itemName=[\w.-]+}i,
    ],
  )
  end
end
