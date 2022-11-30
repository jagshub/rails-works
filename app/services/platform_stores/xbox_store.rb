# frozen_string_literal: true

module PlatformStores
  class XboxStore < Store.new(
    enum: 5,
    name: 'Xbox',
    key: :xbox,
    os: 'Xbox One',
    matchers: [
      %r{^store\.xbox\.com/en-US/#{ DIRECTORIES_ENDING_IN_SLASH }#{ UUID_REGEX }}i,       # Note(andreasklinger): known problem: how to handle other store locales
      %r{^marketplace\.xbox\.com/en-US/#{ DIRECTORIES_ENDING_IN_SLASH }#{ UUID_REGEX }}i, #   eg de-DE instead of en-US
    ],
  )
  end
end
