# frozen_string_literal: true

module API::V2::Types
  class MediaType < BaseObject
    description 'A media object.'

    field :type, String, 'Type of media object.', null: false, method: :kind
    field :url, 'Public URL for the media object. Incase of videos this URL represents thumbnail generated from video.', resolver: API::V2::Resolvers::MediaImageUrlResolver
    field :video_url, String, 'Video URL of the media object.', null: true

    def video_url
      metadata = object.metadata || {}

      url = metadata.dig('url')
      return url if url.present?

      video_id = metadata.dig('video_id')
      platform = metadata.dig('platform')
      return "https://www.youtube.com/embed/#{ video_id }?autohide=1&showinfo=0" if video_id.present? && platform == 'youtube'
    end
  end
end
