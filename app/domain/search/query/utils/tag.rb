# frozen_string_literal: true

# NOTE(DZ): This object parses a query string for specific tags and generate
# elastic appropriate query options.
#
# For example:
#
#   'topic:test' =>
#      { _or: [{ topics: { ilike: 'test' } }] }
#   'topic:test topic:other' =>
#      { _or: [{ topics: { ilike: 'test' } }] }, { _or: [{ topics: { ilike: 'other' } }] }
#   'topic:"test, other" =>
#      { _or: [{ topics: { ilike: 'test' } }, { topics: { ilike: 'other' } }] }
#

class Search::Query::Utils::Tag
  TAG_MAPPER = {
    'topic' => ->(query) { { topics: { ilike: query } } },
    'maker' => ->(query) { { 'meta.makers' => { ilike: query } } },
    'hunter' => ->(query) { { user: { ilike: query } } },
    'alternative' => ->(query) { { related_items: { ilike: query } } },
  }.freeze

  class << self
    # NOTE(DZ): Matches and captures all groups of word:word, word:"word", or
    # word:'word'.
    VALID_KEYS = TAG_MAPPER.keys.join('|').freeze
    REGEX = /((#{ VALID_KEYS })s?+:)("(([^"])*)"|'(([^'])*)'|(([^\s])*))/.freeze

    def parse_raw_query(raw_query)
      return ['*', nil] if raw_query.blank?

      tags = new(raw_query.scan(REGEX))
      query = raw_query.gsub(REGEX, '').gsub(/\s+/, ' ').strip
      query = '*' if query.blank?
      [query, tags]
    end
  end

  attr_reader :tags

  def initialize(scanned_tags)
    @tags = generate_tags_from_scanned_tags(scanned_tags)
  end

  def merge_options(options)
    return if tags.blank?

    options[:where] ||= {}
    options[:where][:_and] ||= []
    options[:where][:_and].concat(tags)
  end

  delegate :blank?, to: :tags

  private

  def generate_tags_from_scanned_tags(scanned_tags)
    scanned_tags.map do |(_, tag, query)|
      query_tokens = query.split(',').map(&:strip)
      query_clauses = query_tokens.flat_map do |query_token|
        generate_clause_from_token(tag, query_token)
      end

      { _or: query_clauses }
    end
  end

  def generate_clause_from_token(tag, token)
    clean_token = token.gsub(/['"]/, '').strip
    tag_proc = TAG_MAPPER[tag]

    raise "Invalid tag #{ tag }" if tag_proc.nil?

    tag_proc.call(clean_token)
  end
end
