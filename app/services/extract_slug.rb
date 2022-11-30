# frozen_string_literal: true

module ExtractSlug
  extend self

  def from_url(url, name)
    return if url.blank?

    url.to_s.gsub(%r{https?://(www\.)?producthunt\.com/#{ name }/}, '')
  end

  def from_path(path, name)
    return if path.blank?

    path.to_s.gsub("/#{ name }/", '')
  end
end
