# frozen_string_literal: true

module MediaUpload::Type::Video
  extend self

  VIDEO_PLATFORMS = {
    youtube: {
      pattern: %r{https?:\/\/((www\.)?youtube\.com\/watch(\?v=|.+\&v=)(?<id>[^#&]+)|youtu\.be\/(?<id>\w+))},
      thumbnail: 'http://img.youtube.com/vi/%<id>s/hqdefault.jpg',
    },
  }.freeze

  def call(video_url)
    return unless video_url.is_a? String

    VIDEO_PLATFORMS.each do |platform, details|
      match = video_url.match(details[:pattern])
      next if match.blank?

      id = match[:id]

      size = FetchSize.call id: id, platform: platform

      return MediaUpload::Info.new(
        image: format(details[:thumbnail], id: id),
        type: :video,
        size: size,
        metadata: { platform: platform, video_id: id, url: video_url },
      )
    end

    nil
  end
end
