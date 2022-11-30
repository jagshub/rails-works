# frozen_string_literal: true

require 'uri'

module UrlParser
  extend self

  def clean_url(url)
    uri = parse_url(Utf8Sanitize.call(url))
    return if uri.blank?

    PlatformStores.match_by_url(url).presence || normalize_default(uri)
  rescue URI::InvalidComponentError
    nil
  end

  def url_valid?(url)
    url =~ URI::DEFAULT_PARSER.make_regexp
  end

  def ph_url?(url)
    %r{\Ahttps?:\/\/(?:w{3}\.)?producthunt\.com\/?.*\z}i.match?(url)
  end

  def clean_product_url(url)
    return unless url_valid?(url)

    url = Utf8Sanitize.call(url)
    platform_url = identify_platform_store_url(url)

    if platform_url
      normalize_platform_url(Addressable::URI.parse(platform_url))
    else
      normalize_default(Addressable::URI.parse(url))
    end
  rescue Addressable::URI::InvalidURIError
    nil
  end

  def final_url_redirect(url, depth: 10)
    return if url.blank?

    HandleNetworkErrors.call(fallback: nil) do
      response = HTTParty.get(url, limit: depth, follow_redirects: true)
      response.request.last_uri.to_s
    end
  end

  private

  # By default we return 'url' as host.tld/path
  def normalize_default(uri)
    path = uri.path[-1, 1] == '/' ? uri.path.chop : uri.path

    uri.host.gsub(/^www\./, '').concat(path).strip.downcase
  end

  # For platform URLs, we want to leave their path and query intact
  def normalize_platform_url(uri)
    uri.host = uri.host.gsub(/^www\./, '').downcase
    uri.to_s.gsub(%r{^https?://}, '').gsub(%r{/$}, '')
  end

  def parse_url(url)
    return if url.blank?

    begin
      uri = URI(url.downcase.strip)
    rescue URI::InvalidURIError, NoMethodError
      return
    end

    return if uri.host.blank?

    uri
  end

  def identify_platform_store_url(url)
    platform_url = PlatformStores.match_by_url(url)
    return if platform_url.blank?

    # NOTE(DZ): Some store urls returns without protocol, add here. There is no
    # difference between http & https since this should go back in to URI class
    if /^https?/.match?(platform_url)
      platform_url
    else
      "https://#{ platform_url }"
    end
  end
end
