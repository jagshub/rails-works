# frozen_string_literal: true

class Graph::Resolvers::Commentables::ThreadsResolver < Graph::Resolvers::BaseSearch
  scope { object.comments.visible.top_level.by_sticky.by_hidden }

  class OrderType < Graph::Types::BaseEnum
    graphql_name 'ThreadOrder'

    value 'DEFAULT'
    value 'DATE'
    value 'VOTES'
  end

  class FilterType < Graph::Types::BaseEnum
    graphql_name 'ThreadFilter'

    value 'REVIEWS'
    value 'COMMENTS'
  end

  option :order, type: OrderType, default: 'DEFAULT'
  option :filter, type: FilterType
  option :no_replies, type: Boolean, with: :apply_no_replies
  option :include_comment_id, type: GraphQL::Types::ID, with: :noop
  option :exclude_comment_id, type: GraphQL::Types::ID, with: :apply_exclude_comment_id

  def apply_order_with_default(scope)
    case object
    when Post
      apply_order_with_votes(scope)
    when ProductRequest
      if object.advice?
        apply_order_with_votes(scope)
      else
        apply_order_with_date(scope)
      end
    else
      apply_order_with_date(scope)
    end
  end

  def apply_order_with_date(scope)
    apply_include_comment_id(scope).order(created_at: :asc)
  end

  def apply_order_with_votes(scope)
    apply_include_comment_id(scope).by_total_votes_count.order(created_at: :asc)
  end

  def apply_filter_with_reviews(scope)
    scope.joins(:review)
  end

  def apply_filter_with_comments(scope)
    scope.includes(:review).where(reviews: { comment_id: nil })
  end

  def apply_no_replies(scope, value)
    return if value.blank?

    scope = scope.where.not(user_id: object.product_makers.pluck(:user_id) + [object.user_id]) if object.is_a?(Post)
    scope.not_hidden.where('replies_count = 0')
  end

  def apply_exclude_comment_id(scope, comment_id)
    comment_id = find_comment_id(comment_id)
    return scope if comment_id.blank?

    scope.where.not(id: comment_id)
  end

  def noop(scope, _comment_id)
    scope
  end

  private

  def apply_include_comment_id(scope)
    comment_id = find_comment_id(params['include_comment_id'])
    return scope if comment_id.blank?

    scope.order([Arel.sql('id = ? DESC'), comment_id])
  end

  def find_comment_id(id)
    return if id.blank?

    comment = Comment.find_by id: id
    comment&.parent_comment_id || comment&.id
  end
end
