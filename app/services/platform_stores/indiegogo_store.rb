# frozen_string_literal: true

module PlatformStores
  class IndiegogoStore < Store.new(
    enum: 17,
    name: 'Indiegogo',
    key: :indiegogo,
    os: 'Web',
    matchers: [
      %r{^indiegogo.com/projects(/[\w\d-]+)}i,
    ],
  )
  end
end
