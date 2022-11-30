# frozen_string_literal: true

module PlatformStores
  class YoutubeStore < Store.new(
    enum: 9,
    key: :youtube,
    name: 'YouTube',
    os: nil,
    matchers: [
      %r{^((m|music)\.)?youtube\.com/watch\?v=\w+}i,
      %r{^((m|music)\.)?youtube\.com/\w+}i,
      %r{^((m|music)\.)?youtu\.be/\w+}i,
    ],
  )
  end
end
