# frozen_string_literal: true

module PlatformStores
  class GoogleStore < Store.new(
    enum: 36,
    name: 'Google',
    key: :google,
    os: 'Web',
    matchers: [
      %r{^books\.google\.com/books\?id=\w+}i,
      %r{^workspace\.google\.com/marketplace/app/[^/]+/\d+}i,
      %r{^workspace\.google\.com/u/\d/marketplace/app/[^/]+/\d+}i,
      %r{^drive\.google\.com/open\?id=[\w._-]+}i,
      %r{^drive\.google\.com/file/d/[\w._-]+/view}i,
      %r{^drive\.google\.com/drive/folders/[\w._-]+}i,
      %r{^drive\.google\.com/uc\?.*+}i,
      %r{^docs\.google\.com/\w+/[^?#]+}i,
      %r{^script\.google\.com/[^?#]+}i,
      %r{^sites\.google\.com/\w+/[^?#]+}i,
      %r{^[\w+_-]+\.sites\.google\.com/\w+/[^?#]+}i,
      %r{^gsuite\.google\.com/\w+/[^?#]+}i,
    ],
  )
  end
end
