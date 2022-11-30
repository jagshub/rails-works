# frozen_string_literal: true

require 'open-uri'
require 'active_support/core_ext'

module External::SimpleCastApi
  extend self

  RSS_URL = 'https://rss.simplecast.com/podcasts/6261/rss'
  GE_URL = 'https://rss.simplecast.com/podcasts/7553/rss'

  FEEDS = {
    'ge' => ['simple_cast_rss_ge_feed', GE_URL],
    'all' => ['simple_cast_rss_all_feed', RSS_URL],
  }.freeze

  def podcast_feed(feed_type, limit)
    feed = rss_feed_data(feed_type).dig('rss', 'channel', 'item') || []

    latest = feed.select { |item| Date.parse(item['pubDate']).year >= 2018 }

    latest = latest.first(limit) if limit.present?

    latest.map do |podcast|
      PodcastEpisode.new(
        name: podcast_title(podcast['title']),
        cover_art_url: podcast.dig('image', 'href') || S3Helper.image_url('ph-logo-2.png'),
        url: podcast.dig('enclosure', 'url') || '',
      )
    end
  end

  private

  def podcast_title(title)
    title.is_a?(Array) ? title.first : (title.presence || 'Not available')
  end

  def rss_feed_data(feed_type)
    HandleNetworkErrors.call(fallback: {}) do
      cache_name, feed_url = FEEDS[feed_type] || FEEDS['all']

      Rails.cache.fetch(cache_name, expires_in: 6.hours) do
        Hash.from_xml(URI.parse(feed_url).open(open_timeout: 1, read_timeout: 1))
      end
    end
  end

  class PodcastEpisode
    attr_reader :name, :cover_art_url, :url

    def initialize(name:, cover_art_url:, url:)
      @name = name
      @cover_art_url = cover_art_url
      @url = url
    end
  end
end
