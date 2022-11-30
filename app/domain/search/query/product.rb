# frozen_string_literal: true

class Search::Query::Product < Search::Query::Base
  attr_reader :other_opts

  OPTIONS_MAP = {
    featured: ->(featured) { featured ? { 'meta.featured' => true } : nil },
    maker: ->(maker) { { 'meta.makers' => { ilike: maker } } },
    last_launched_after: lambda do |last_launched_after|
      timestamp = Search::Query::Utils::Helpers.date_key_to_time(last_launched_after)
      timestamp && { 'meta.last_launched_at' => { gte: timestamp } }
    end,
    exclude_ids: ->(ids) { { id: { not: ids } } },
  }.freeze

  OPTIONS_DEFAULT = {
    featured: false,
    maker: nil,
    last_launched_after: nil,
    exclude_ids: nil,
  }.freeze

  def initialize(query, **other_opts)
    @other_opts = Search::Query::Utils::Options.new(
      OPTIONS_MAP,
      OPTIONS_DEFAULT.merge(other_opts.compact),
    )

    super(query)
  end

  def execute(options = {})
    @other_opts.merge_options(options)

    super(options)
  end

  def base_options
    @base_options ||= {
      models: [Product],
      fields: %w(
        name^8
        topics^8
        body^2
        meta.launches^6
        related_items^1
      ),
    }
  end

  def get_function
    {
      functions: [{
        script_score: {
          script: {
            params: {
              score_w: 0.6,
              vote_w: 0.4,
            },
            source: <<-TEXT.squish.squeeze(' '),
              Math.pow(_score, params.score_w) *
              Math.pow(doc['votes_count'].value, params.vote_w)
            TEXT
          },
        },
      }, {
        gauss: {
          'meta.last_launched_at': {
            offset: '180d',
            scale: '730d',
            decay: 0.7,
          },
        },
      }],
      boost_mode: 'replace',
    }
  end
end
