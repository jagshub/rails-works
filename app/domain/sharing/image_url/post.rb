# frozen_string_literal: true

module Sharing::ImageUrl::Post
  extend self

  HEIGHT = 512
  WIDTH = 1024

  def call(post, width: WIDTH, height: HEIGHT)
    uuid =
      post.social_media_image_uuid ||
      post.images.by_priority.first&.uuid ||
      post.thumbnail_image_uuid

    Image.call uuid, width: width, height: height, fit: 'crop', frame: 1
  end
end
