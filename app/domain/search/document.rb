# frozen_string_literal: true

class Search::Document
  attr_reader :record, :overrides

  OVERRIDES = %i(
    body
    created_at
    meta
    name
    related_items
    topics
    user
    votes_count
  ).freeze

  def initialize(record, **overrides)
    unknown_keys = overrides.keys - OVERRIDES
    raise "Unknown overrides passed - #{ unknown_keys }" if unknown_keys.any?

    @record = record
    @overrides = overrides
  end

  # NOTE(DZ): Default :name or :title
  def name
    return overrides[:name] if overrides.key?(:name)

    fetch(:name) || fetch(:title)
  end

  # NOTE(DZ): Default tagline + description
  def body
    return overrides[:body] if overrides.key?(:body)

    body = [fetch(:tagline), fetch(:description)].compact
    body.presence
  end

  # NOTE(DZ): Default topic record association converted into array of names
  def topics
    return overrides[:topics] if overrides.key?(:topics)

    topics = fetch(:topics)
    return if topics.blank?

    topics.map(&:name)
  end

  # NOTE(DZ): We use array values for user fields (name, username) so searching
  # for either gives us this document. This may create issues in the future
  # https://www.elastic.co/guide/en/elasticsearch/guide/current/_multivalue_fields_2.html
  def user
    return overrides[:user] if overrides.key?(:user)

    user = fetch(:user)
    return if user.blank?

    [user.name, user.username].compact
  end

  # NOTE(DZ): Field should be present as it is used in scoring
  def votes_count
    return overrides[:votes_count] if overrides.key?(:votes_count)

    fetch(:credible_votes_count) || fetch(:votes_count) || 0
  end

  def created_at
    return overrides[:created_at] if overrides.key?(:created_at)

    fetch(:created_at)
  end

  # NOTE(DZ): related_items is an override only array of strings.
  def related_items
    overrides[:related_items]
  end

  # NOTE(DZ): meta is an override only hash.
  def meta
    overrides[:meta]
  end

  # NOTE(DZ): Document should always have searchable_conversions, assoc is
  # declared by Search::Searchable
  def conversions
    # NOTE(DZ): Do not use AR methods of group/count. Instead, use ruby version
    # to avoid additional queries.
    record.searchable_conversions.group_by do |conversion|
      escape_string(conversion.user_search.normalized_query)
    end.transform_values(&:size)
  end

  # NOTE(DZ): Updates to this method (and all #searchable_data methods) will
  # require reindexing
  def to_h
    {
      name: name,
      body: body,
      user: user,
      topics: topics,
      related_items: related_items,
      votes_count: votes_count,
      meta: meta,
      # NOTE(DZ): Turn off conversions to CTR Test
      # conversions: conversions,
      created_at: created_at,
    }.compact
  end

  private

  def fetch(field)
    record.public_send(field) if record.respond_to?(field)
  end

  def escape_string(string)
    string.gsub('.', '\.')
  end
end
