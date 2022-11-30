# frozen_string_literal: true

module NormalizeTwitter
  extend self

  def username(input)
    input.to_s.split('/').last.to_s.strip.downcase.sub('@', '').presence
  end

  def url(input)
    handle = username(input)
    "https://twitter.com/#{ handle }" if handle.present?
  end
end
