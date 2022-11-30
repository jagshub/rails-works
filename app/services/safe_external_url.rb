# frozen_string_literal: true

module SafeExternalUrl
  extend self

  def call(host, input, extra_path = nil)
    uri = URI.parse(input)
    return unless valid?(host, uri)

    build_full_url(host, uri, extra_path)
  rescue URI::InvalidURIError, NoMethodError, URI::InvalidComponentError
    nil
  end

  private

  def valid?(host, uri)
    return false if uri.path.blank?
    return false if uri.path == '/'
    return false if uri.host.present? && uri.host.sub(/^www\./, '') != host.sub(/^www\./, '')

    true
  end

  def build_full_url(host, uri, extra_path)
    path = uri.path.starts_with?('/') ? uri.path : "/#{ uri.path }"
    safe_url = "#{ host }#{ path }/#{ extra_path }".squeeze('/')

    "https://#{ safe_url }".chomp('/')
  end
end
