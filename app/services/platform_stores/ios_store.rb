# frozen_string_literal: true

module PlatformStores
  class IOSStore < Store.new(
    enum: 1,
    name: 'App Store',
    key: :ios,
    os: 'iOS',
    matchers: [
      # Note(AR): itunes could have another subdomain, so no ^
      %r{itunes\.apple\.com/WebObjects/MZStore.woa/wa/viewSoftware\?id=\d+}i,
      %r{itunes\.apple\.com(/[\w-]+){2,4}}i, # itunes.apple.com/(COUNTRY/)app/PUBLISHER/idID
      %r{^apps\.apple\.com(/[\w-]+){2,4}}i, # apps.apple.com/(COUNTRY/)app/PUBLISHER/idID
      %r{^appstore.com(/[\w-]+){1,3}}i, # appstore.com/COMPANY/APPNAME
      %r{^appsto.re(/[\w-]+){2,4}}i,
    ],
  )
  end
end
