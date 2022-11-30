# frozen_string_literal: true

require 'uri'
require 'ipaddr'

# NOTE(rstankov): Protects against Blind Server Side Request Forgery
#   > SSRF flaws occur whenever a web application is fetching a remote resource without
#   > validating the user-supplied URL. It allows an attacker to coerce the application to send a
#   > crafted request to an unexpected destination, even when protected by a firewall, VPN, or
#   > another type of network access control list (ACL). Blind SSRF vulnerabilities arise when an
#   > application can be induced to issue a back-end HTTP request to a supplied URL, but the
#   > response from the back-end request is not returned in the application's front-end response.
#
#  We shouldn't allow to upload URI which are localhost or private to our system
module Image::UrlValidator
  extend self

  ALLOW_PORTS = [80, 443].freeze # http / https
  ALLOW_SCHEMA = %w(http https).freeze

  # NOTE(rstankov): List of rejected hosts
  # Taken from https://gist.github.com/tinogomes/c425aa2a56d289f16a1f4fcb8a65ea65
  # Overtime we should include our private URIs
  FILTER_LIST = [
    /^localhost$/,
    /^*.\.fbi\.com$/,
    /^*.\.localtest\.me$/,
    /^*.\.127-0-0-1\.org\.uk$/,
    /^*.\.vcap\.me$/,
    /^*.\.yoogle\.com$/,
    /^*.\.lacolhost\.com$/,
    /^*.\.local\.sisteminha\.com$/,
    /^domaincontrol\.com$/,
  ].freeze

  def allow?(url)
    return false if url.blank?

    uri = URI.parse(url)

    return false unless ALLOW_SCHEMA.include? uri.scheme
    return false unless ALLOW_PORTS.include? uri.port
    return false if ip_address? uri.host
    return false if FILTER_LIST.any? { |regexp| regexp.match?(uri.host) }

    true
  rescue URI::InvalidURIError
    false
  end

  private

  def ip_address?(host)
    IPAddr.new(host)
    true
  rescue IPAddr::InvalidAddressError
    false
  end
end
