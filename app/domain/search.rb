# frozen_string_literal: true

module Search
  extend self

  def query(query, models: [], &block)
    Search::Query::Base.new(query, models: models, &block)
  end

  def query_post(query, **options, &block)
    Search::Query::Post.new(query, **options, &block)
  end

  def query_product(query, **options)
    Search::Query::Product.new(query, **options)
  end

  def query_collection(query, **options)
    Search::Query::Collection.new(query, **options)
  end

  def query_user(query, **options)
    Search::Query::User.new(query, **options)
  end

  def query_discussion(query)
    Search::Query::Discussion.new(query)
  end

  def dev_query_product(query, rank_by:, weight:, decay:, boosts:)
    Search::Query::DevProduct.new(
      query,
      rank_by: rank_by,
      weight: weight,
      decay: decay,
      boosts: boosts,
    )
  end

  def track(query, models:, user: nil, platform: :web)
    return if query.blank? || query == '*' || models.blank?

    search_type =
      if models.size != Search::Searchable.models.size
        Array(models).map(&:to_s).sort.join(' ')
      else
        'All Indices'
      end

    Search::UserSearch.create!(
      search_type: search_type,
      query: query,
      user: user,
      platform: platform,
    )
  end

  def append_topics_aggs(body, first: 5)
    # https://www.elastic.co/guide/en/elasticsearch/reference/current/search-aggregations-bucket-terms-aggregation.html
    body[:aggs] ||= {}
    body[:aggs][:topics] = { terms: { field: 'topics', size: first } }
  end

  def document(record, overrides = {})
    Search::Document.new(record, overrides)
  end

  def environment_allows_indexing?
    Rails.env.production? || Config.index_elasticsearch
  end

  def track_result(search_id:, subject:, source:)
    Search::Track.convert(
      search_id: search_id,
      subject: subject,
      source: source,
    )
  end

  def trending_queries(limit: 5)
    Search::Trending.queries(limit: limit)
  end

  # NOTE(DZ): We have custom callbacks for indexing and searching on after_save
  # events. This block is thread safe method to turn off indexing. We cannot
  # use Searchkick.callbacks_value because we hardcode the value to be false.
  def without_indexing
    self.disable_indexing = true
    yield
    self.disable_indexing = false
  end

  def disable_indexing
    Thread.current[:search_disable_indexing]
  end

  def disable_indexing=(value)
    Thread.current[:search_disable_indexing] = value
  end

  def index_cron_worker
    Search::Workers::IndexCronWorker
  end

  def searchable
    Search::Searchable
  end

  def searchable_association
    Search::SearchableAssociation
  end
end
