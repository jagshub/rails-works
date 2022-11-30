# frozen_string_literal: true

class Search::Query::Base
  attr_reader :query, :models, :tags, :block

  MAX_COUNT = 1_000

  def initialize(raw_query, models: [], &block)
    @query, @tags = Search::Query::Utils::Tag.parse_raw_query(raw_query)
    @query = query[0..255] if query.length > 255
    @block = block
    @models = models.present? ? Array(models) : Search::Searchable.models
  end

  def execute(options = {})
    tags.merge_options(options) if tags.present?

    Searchkick.search(
      query,
      base_options.merge(options),
      &method(:modify_query_body)
    )
  end

  private

  def base_options
    @base_options ||= {
      models: models,
      fields: [
        'name^10',
        'body^2',
        'topics^2',
        'meta.url^10',
        'related_items^1',
        'user^1',
      ],
      indices_boost: {
        Product => 10,
        Post => 4,
        Topic => 4,
        Discussion::Thread => 2,
        User => 2,
        Anthologies::Story => 2,
        UpcomingPage => 1,
      },
      body_options: {
        track_total_hits: MAX_COUNT,
      },
    }
  end

  VOTE_SCORE = {
    script_score: {
      script: "_score * Math.log(1 + (doc['votes_count'].value) / 1000.0)",
    },
  }.freeze

  def get_function
    VOTE_SCORE
  end

  def modify_query_body(body)
    function = get_function

    if body[:query][:bool]
      bool = body[:query].delete(:bool)
      function_score = { query: { bool: bool } }.merge(function)
    else
      match_all = body[:query].delete(:match_all)
      function_score = { query: { match_all: match_all } }.merge(function)
    end

    block&.call(body)

    body[:query][:function_score] = function_score
  end

  # NOTE(DZ): GraphQL Connection wrapper
  class Connection < GraphQL::Pagination::Connection
    DEFAULT_PAGE_SIZE = 20

    attr_accessor :results

    # NOTE(DZ): Graph::Types::BaseConnection calls #total_count
    delegate :total_count, to: :results

    def results
      @results ||= items.execute(per_page: per_page, page: page)
    end

    def nodes
      results
    end

    def has_previous_page # rubocop:disable Naming/PredicateName
      !results.first_page?
    end

    def has_next_page # rubocop:disable Naming/PredicateName
      !results.last_page?
    end

    def cursor_for(item)
      index = results.find_index(item)
      return encode('Rank:1') if index.nil?

      # NOTE(DZ): Rank uses 1-based indexing, add 1 here from #find_index
      encode("Rank:#{ index + 1 + offset }")
    end

    def end_cursor
      nodes.results && cursor_for(nodes.results.last)
    end

    def results_count
      results.total_count
    end

    def aggregations
      buckets = results.aggregations.dig('topics', 'buckets')
      return { topics: [] } if buckets.blank?

      buckets = buckets.to_h { |b| [b['key'], b['doc_count']] }
      topics =
        Topic
        .where(name: buckets.keys)
        .group_by(&:name)
        .map do |_, (topic)|
          # NOTE(DZ): Only 1 topic per name (unique index)
          { topic: topic, count: buckets[topic.name] }
        end

      { topics: topics.sort_by { |t| -t[:count] } }
    end

    def search_id
      return if results.search.blank?

      results.search.id
    end

    private

    def per_page
      @per_page ||= first_value || DEFAULT_PAGE_SIZE
    end

    # NOTE(DZ): Page uses 1-based indexing
    def page
      @page ||= (rank_from_cursor(after_value) / per_page) + 1
    end

    def offset
      @offset = per_page * (page - 1)
    end

    def rank_from_cursor(cursor)
      return 1 if cursor.nil?

      rank = decode(cursor).scan(/^Rank:(\d+)$/).flatten
      raise "Bad cursor - #{ cursor }" if rank.blank?

      rank[0].to_i
    end
  end
end
