# frozen_string_literal: true

module Sharing::ImageUrl::UpcomingPage
  extend self

  HEIGHT = 512
  WIDTH = 1024

  def call(upcoming_page)
    return Image.call(upcoming_page.seo_image_uuid) if upcoming_page.seo_image_uuid?
    return if upcoming_page.background_image_uuid.blank? || upcoming_page.logo_uuid.blank?

    Image.call upcoming_page.background_image_uuid, width: 1024, height: 512, fit: 'crop', blend: upcoming_page.logo_uuid, frame: 1
  end
end
