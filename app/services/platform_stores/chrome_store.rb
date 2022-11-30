# frozen_string_literal: true

module PlatformStores
  class ChromeStore < Store.new(
    enum: 3,
    name: 'Chrome',
    key: :chrome,
    os: 'Web',
    matchers: [
      %r{^chrome\.google\.com/webstore/detail/[^/]+/\w+}i, # chrome.google.com/webstore/detail/APPNAME/ID
      %r{^chrome\.google\.com/webstore/detail/[^/]+}i,     # chrome.google.com/webstore/detail/APPNAME
    ],
  )
  end
end
