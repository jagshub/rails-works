# frozen_string_literal: true

class Search::Query::Post < Search::Query::Base
  attr_reader :other_opts

  OPTIONS_MAP = {
    featured: ->(featured) { featured ? { 'meta.featured' => true } : nil },
    show_sunset: ->(sunset) { sunset ? nil : { 'meta.sunset' => false } },
    topics: ->(topics) { { topics: Array(topics) } },
    posted_after: lambda do |posted|
      timestamp = Search::Query::Utils::Helpers.date_key_to_time(posted)
      timestamp && { created_at: { gte: timestamp } }
    end,
    maker: ->(maker) { { 'meta.makers' => { ilike: maker } } },
  }.freeze

  OPTIONS_DEFAULT = {
    featured: false,
    show_sunset: false,
    posted_after: nil,
    topics: nil,
    maker: nil,
  }.freeze

  def initialize(query, trend: false, **other_opts, &block)
    @other_opts = Search::Query::Utils::Options.new(
      OPTIONS_MAP,
      OPTIONS_DEFAULT.merge(other_opts.compact),
    )
    @trend = trend
    super(query, models: [Post], &block)
  end

  def execute(options = {})
    other_opts.merge_options(options)

    super(options)
  end

  TREND_SCORE = {
    functions: [
      {
        gauss: {
          created_at: {
            origin: Time.current,
            offset: '12h',
            scale: '7d',
            decay: 0.3,
          },
        },
      },
      {
        gauss: {
          votes_count: {
            origin: 10_000,
            scale: 10_000,
          },
        },
      },
    ],
  }.freeze
  def get_function
    @trend ? TREND_SCORE : super
  end
end
