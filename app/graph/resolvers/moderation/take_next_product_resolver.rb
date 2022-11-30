# frozen_string_literal: true

class Graph::Resolvers::Moderation::TakeNextProductResolver < Graph::Resolvers::Base
  type Graph::Types::ProductType, null: true

  argument :query, String, required: false
  argument :clear_lock, Boolean, required: false
  argument :only_scraped, Boolean, required: false

  def resolve(query: nil, clear_lock: false, only_scraped: false)
    return if current_user.blank?

    ModerationLock.unlock_all(type: 'Product', user: current_user) if clear_lock

    products = Product.where(reviewed: false).order(created_at: :desc)
    products = ModerationSkip.exclude_skipped(products, user_id: current_user.id)
    products = apply_query(products, query)
    products = apply_only_scraped(products, only_scraped)

    ModerationLock.take_first(products, user: current_user)
  end

  private

  # TODO: Copied from app/graph/resolvers/products/search_resolver.rb
  def apply_query(scope, value)
    return scope if value.blank?

    vector_sql = "to_tsvector('english', name)"
    query_sql = ActiveRecord::Base.sanitize_sql(["plainto_tsquery('english', ?)", value])

    scope
      .where(Arel.sql("#{ vector_sql } @@ #{ query_sql }"))
      .reorder(Arel.sql("ts_rank_cd(#{ vector_sql }, #{ query_sql }) DESC"))
  end

  def apply_only_scraped(scope, value)
    return scope unless value

    scope.product_scraper
  end
end
