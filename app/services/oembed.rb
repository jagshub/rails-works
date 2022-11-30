# frozen_string_literal: true

module Oembed
  extend self

  ENDPOINTS = [
    Endpoints::CommentsEndpoint,
    Endpoints::PostsEndpoint,
    Endpoints::ProductsEndpoint,
  ].freeze

  def fetch(url:, maxwidth: nil, maxheight: nil)
    return if url.blank?

    ENDPOINTS.each do |endpoint|
      response = endpoint.fetch(url: url, maxwidth: maxwidth, maxheight: maxheight)
      return response if response
    end

    nil
  end
end
