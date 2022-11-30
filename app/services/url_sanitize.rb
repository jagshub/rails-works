# frozen_string_literal: true

require 'uri'

module UrlSanitize
  extend self

  WHITELISTED_HOSTS = ['producthunt.com', 'ph.test', 'producthunt.org'].freeze

  def whitelisted_hosts
    WHITELISTED_HOSTS
  end

  def call(url)
    uri = URI.parse(url)

    return if uri.blank?
    return [sane_path(uri.path), uri.query].compact.join('?') if uri.host.blank?
    return unless whitelisted_host?(uri.host)

    uri.to_s
  rescue URI::InvalidURIError
    nil
  end

  private

  # Note(andreasklinger): Ensure we prefix with / to avoid redirects to
  #    http://www.producthunt.com.evilhacker.org
  def sane_path(path)
    path.starts_with?('/') ? path : "/#{ path }"
  end

  # Note(andreasklinger): Allow api.producthunt.com or www.producthunt.com
  def whitelisted_host?(host)
    domain = host.split('.').last(2).join('.')
    whitelisted_hosts.include? domain
  end
end
