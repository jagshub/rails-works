# frozen_string_literal: true

module MediaUpload::Type::Video::FetchSize
  extend self

  def call(id:, platform:)
    fetch_size_from_youtube_video_id(id) if platform == :youtube
  end

  private

  def fetch_size_from_youtube_video_id(id)
    url = "https://www.youtube.com/oembed?url=http%3A//www.youtube.com/watch?v%3D#{ id }&format=json"
    response = HTTParty.get(url)

    if response.code == 200
      { original_width: response['width'], original_height: response['height'] }
    else
      {}
    end
  rescue URI::InvalidURIError
    {}
  end
end
