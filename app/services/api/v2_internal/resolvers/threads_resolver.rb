# frozen_string_literal: true

class API::V2Internal::Resolvers::ThreadsResolver < API::V2Internal::Resolvers::BaseSearchResolver
  scope { object.comments.visible.top_level.by_sticky }

  class OrderType < Graph::Types::BaseEnum
    graphql_name 'ThreadOrder'

    value 'DEFAULT'
    value 'DATE'
    value 'VOTES'
  end

  option :order, type: OrderType, default: 'DEFAULT'
  option :include_comment_id, type: GraphQL::Types::ID, with: :noop
  option :has_no_replies, type: Boolean, with: :apply_has_no_replies

  type API::V2Internal::Types::CommentType.connection_type, null: false

  def apply_order_with_default(scope)
    apply_order_with_date(scope)
  end

  def apply_order_with_date(scope)
    scope = apply_include_comment_id(scope)
    scope.order(created_at: :asc)
  end

  def apply_order_with_votes(scope)
    scope = apply_include_comment_id(scope)

    scope.by_total_votes_count.order(created_at: :asc)
  end

  def apply_has_no_replies(scope, value)
    return if value.blank?

    scope = scope.where.not(user_id: object.product_makers.pluck(:user_id) + [object.user_id]) if object.is_a?(Post)
    scope.not_hidden.where('replies_count = 0')
  end

  # NOTE(rstankov): Left here as pass through
  def noop(scope, _comment_id)
    scope
  end

  private

  def apply_include_comment_id(scope)
    return scope if params['include_comment_id'].nil?

    comment = Comment.find_by id: params['include_comment_id']

    return scope if comment.nil?

    scope.order([Arel.sql('id = ? DESC'), comment.parent_comment_id || comment.id])
  end
end
