# frozen_string_literal: true

module Sharing::ImageUrl::UpcomingEvent
  extend self

  def call(upcoming_event)
    External::Url2pngApi.share_url(upcoming_event)
  end
end
