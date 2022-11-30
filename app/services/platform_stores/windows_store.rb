# frozen_string_literal: true

module PlatformStores
  class WindowsStore < Store.new(
    enum: 7,
    name: 'Windows',
    key: :windows,
    os: 'Windows',
    matchers: [
      %r{^windowsphone\.com/en-us/store/#{ DIRECTORIES_ENDING_IN_SLASH }#{ UUID_REGEX }}i,
      %r{^apps\.microsoft\.com/windows/en-us/#{ DIRECTORIES_ENDING_IN_SLASH }#{ UUID_REGEX }}i,
    ],
  )
  end
end
