# frozen_string_literal: true

class Mobile::Graph::Resolvers::Products::Reviews < Mobile::Graph::Resolvers::BaseSearchResolver
  scope { object.reviews.by_rating.with_hidden_reviews_at_end }

  class OrderType < Mobile::Graph::Types::BaseEnum
    graphql_name 'ReviewsOrder'

    value 'LATEST'
    value 'HELPFUL'
    value 'FAVORABLE'
    value 'CRITICAL'
  end

  option :order, type: OrderType, default: 'HELPFUL'
  option :include_review_id, type: GraphQL::Types::ID, with: :apply_include_review_id
  option :has_rating, type: Boolean, with: :apply_has_rating
  option :has_body, type: Boolean, with: :with_body_or_experience

  private

  def apply_has_rating(scope, value)
    scope.with_rating if value
  end

  def with_body_or_experience(scope, value)
    scope.with_body_for_mobile if value
  end

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
end
