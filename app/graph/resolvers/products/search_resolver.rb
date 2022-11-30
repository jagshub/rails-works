# frozen_string_literal: true

class Graph::Resolvers::Products::SearchResolver < Graph::Resolvers::BaseSearch
  scope { Product.all }

  class OrderEnum < Graph::Types::BaseEnum
    graphql_name 'ProductsOrder'

    value 'most_recent'
    value 'oldest'
    value 'posts_count'
    value 'most_followed'
    value 'best_rated'
  end

  option :query, type: String, with: :apply_query
  option :order, type: OrderEnum, default: 'most_recent'
  option :period, type: String, with: :apply_period
  option :exclude_hidden, type: Boolean, with: :apply_exclude_hidden
  option :exclude_ph, type: Boolean, with: :apply_exclude_ph
  option :only_scraped, type: Boolean, with: :apply_only_scraped
  option :topic, type: String, with: :apply_topic

  PRODUCT_HUNT_ID = 112_572

  private

  def apply_exclude_ph(scope, value)
    return scope unless value

    scope.where.not(id: PRODUCT_HUNT_ID)
  end

  def apply_query(scope, value)
    return if value.blank?

    starts_with_query = LikeMatch.start_with(query)
    full_match_query = LikeMatch.contains_word(value)
    partial_match_query = LikeMatch.simple(value)

    # Note(Denys): Simple search ranking to return full matches first, then partial name matches, and at the end,
    # partial tagline matches, since they can give many false positives.
    order_sql = ActiveRecord::Base.sanitize_sql(
      [
        <<~SQL.squish,
          CASE
          WHEN LOWER(products.name) =     :query               THEN 1 /* full name equality        */
          WHEN LOWER(products.name) ~     :full_match_query    THEN 2 /* full name match           */
          WHEN products.name        ILIKE :starts_with_query   THEN 3 /* starts with partial match */
          WHEN products.name        ILIKE :partial_match_query THEN 4 /* partial name match        */
          WHEN products.tagline     ILIKE :partial_match_query THEN 5 /* tagline match             */
          ELSE 6 /* no match */
          END ASC
        SQL
        query: query,
        full_match_query: full_match_query,
        starts_with_query: starts_with_query,
        partial_match_query: partial_match_query,
      ],
    )

    query_scope = Product
      .where('products.name ILIKE :query OR products.tagline ILIKE :query', query: partial_match_query)
      .order(Arel.sql(order_sql))

    # Note(Denys): Merging scopes here to ensure query order has a priority.
    query_scope.merge(scope)
  end

  def apply_order_with_most_recent(scope)
    scope.order(created_at: :desc)
  end

  def apply_order_with_oldest(scope)
    scope.order(created_at: :asc)
  end

  def apply_order_with_posts_count(scope)
    scope.order(posts_count: :desc)
  end

  def apply_exclude_hidden(scope, value)
    return scope unless value

    scope.visible
  end

  def apply_only_scraped(scope, value)
    return scope unless value

    scope.product_scraper
  end

  def apply_order_with_best_rated(scope)
    ::Products::WeightedReviewsRating.order(scope, fetch_reviews: params['period'].present?)
  end

  def apply_order_with_most_followed(scope)
    return scope.order(followers_count: :desc, created_at: :desc) unless params['period']

    # Note(Denys): We can't use cached column `followers_count` if `period` param was given.
    scope
      .joins(:subscriptions)
      .group('products.id')
      .order('COUNT(subscriptions.id) DESC, reviews_rating DESC, products.created_at DESC')
  end

  def apply_period(scope, value)
    start_date = Date.strptime(value, '%Y-%m')
    period = start_date..start_date.end_of_month

    case params['order']
    when 'best_rated'
      scope.merge(Review.where(created_at: period))
    when 'most_followed'
      scope.merge(Subscription.where(created_at: period))
    else
      scope.merge(Product.where(created_at: period))
    end
  end

  def apply_topic(scope, value)
    return scope unless value

    scope.joins(:topics).where(topics: { slug: value })
  end
end
