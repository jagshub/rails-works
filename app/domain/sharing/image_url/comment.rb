# frozen_string_literal: true

module Sharing::ImageUrl::Comment
  extend self

  def call(comment)
    External::Url2pngApi.share_url(comment)
  end
end
