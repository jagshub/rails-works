# frozen_string_literal: true

class Search::Query::User < Search::Query::Base
  attr_reader :other_opts

  OPTIONS_MAP = {
    maker: ->(maker) { maker ? { 'meta.maker' => true } : nil },
    hunter: ->(hunter) { hunter ? { 'meta.hunter' => true } : nil },
  }.freeze

  OPTIONS_DEFAULT = {
    maker: true,
    hunter: true,
  }.freeze

  def initialize(query, **other_opts, &block)
    @other_opts = Search::Query::Utils::Options.new(
      OPTIONS_MAP,
      OPTIONS_DEFAULT.merge(other_opts.compact),
    )

    super(query, models: [User], &block)
  end

  def execute(options = {})
    other_opts.merge_options(options)

    super(options)
  end
end
