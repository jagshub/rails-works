# frozen_string_literal: true

module PlatformStores
  class WebflowStore < Store.new(
    enum: 35,
    name: 'Webflow',
    key: :webflow,
    os: 'Web',
    matchers: [
      %r{^university.webflow.(com|io)/(courses/)?[\w\d-]+}i,
      %r{^ebooks.webflow.(com|io)/[\w\d-]+/[\w\d-]+}i,
      %r{^webflow.(com|io)/templates/[/\w\d-]+}i,
    ],
  )
  end
end
