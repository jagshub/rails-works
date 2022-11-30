# frozen_string_literal: true

module Sharing::ImageUrl::AnthologiesStory
  extend self

  def call(story)
    return story.social_image_url if story.social_image_url.present?

    return if story.header_image_uuid.blank?

    Image.call story.header_image_uuid, width: 1024, height: 512, fit: 'crop', frame: 1
  end
end
