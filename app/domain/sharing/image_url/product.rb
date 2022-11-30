# frozen_string_literal: true

module Sharing::ImageUrl::Product
  extend self

  def call(product)
    upcoming_event = product.active_upcoming_event
    return Sharing::ImageUrl::UpcomingEvent.call(upcoming_event) if upcoming_event

    post = product.latest_post
    return Media.empty_image_url if post.blank?

    Sharing::ImageUrl::Post.call(post)
  end
end
