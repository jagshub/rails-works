# frozen_string_literal: true

module ShortLinkBuilder
  extend self

  REF_PARAM = { 'ref' => 'producthunt' }.freeze
  AMAZON_TRACKING_PARAM = { 'tag' => 'prodhunt04-20' }.freeze
  ITUNES_TRACKING_PARAM = { 'at' => '1000l6eA' }.freeze

  def build(url, store)
    return url if blacklisted?(url)

    uri          = Addressable::URI.parse(url)
    query_params = build_query_params(uri.query, store)
    uri.query    = build_query_string(query_params)

    uri.to_s
  end

  private

  def build_query_params(query, store)
    query_params = parse_nested_query(query).merge(REF_PARAM)
    query_params.merge!(AMAZON_TRACKING_PARAM) if PlatformStores::AmazonStore.key?(store)
    query_params.merge!(ITUNES_TRACKING_PARAM) if PlatformStores::IOSStore.key?(store)
    query_params
  end

  def parse_nested_query(query)
    Rack::Utils.parse_nested_query(query)
  rescue Rack::QueryParser::InvalidParameterError
    {}
  end

  def build_query_string(hash)
    Rack::Utils.build_nested_query(hash)
  end

  # Note(andreasklinger): In some cases we do not add our `?ref=` to avoid breaking
  #   target site behaviour
  def blacklisted?(url)
    hash_bang_url?(url)
  end

  # Note(andreasklinger): playstation store features http://fancy.com/#!/urls that
  #   get really easy confused.
  def hash_bang_url?(url)
    url.include?('#!/')
  end
end
