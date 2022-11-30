# frozen_string_literal: true

class Graph::Resolvers::Reviews < Graph::Resolvers::BaseSearch
  scope { object.reviews.not_hidden.by_rating }

  class OrderType < Graph::Types::BaseEnum
    graphql_name 'ReviewsOrder'

    value 'LATEST'
    value 'HELPFUL'
    value 'FAVORABLE'
    value 'CRITICAL'
  end

  option :order, type: OrderType, default: 'HELPFUL'
  option :include_review_id, type: GraphQL::Types::ID, with: :apply_include_review_id
  option :query, type: String, with: :for_query

  private

  def apply_order_with_latest(scope)
    scope.order(created_at: :desc)
  end

  def apply_order_with_helpful(scope)
    scope.by_credible_votes_count_ranking
  end

  def apply_order_with_favorable(scope)
    scope.order(rating: :desc, sentiment: :desc).by_credible_votes_count_ranking
  end

  def apply_order_with_critical(scope)
    scope.order(rating: :asc, sentiment: :asc).by_credible_votes_count_ranking
  end

  def apply_include_review_id(scope, _review)
    review = Review.find_by(id: params['include_review_id']) if params['include_review_id']

    return scope if review.blank?

    object.reviews.order([Arel.sql('id = ? DESC'), review.id])
  end

  def for_query(scope, value)
    return if value.blank?

    scope.with_query(value)
  end
end
