# frozen_string_literal: true

module API::V2::Resolvers
  class Comments::SearchResolver < BaseSearchResolver
    # NOTE(dhruvparmar372): Type needs to be explicitly set to connection_type
    # here because Member::BuildType.to_type_name fails here https://github.com/rmosolgo/graphql-ruby/blob/545a3acf885f97489c154eb63d7975228fa80a99/lib/graphql/schema/field.rb#L114
    # for some reason
    type ::API::V2::Types::CommentType.connection_type, null: false

    # TODO(dhruvparmar372): Explore batch loading here
    scope do
      if object.respond_to?(:comments)
        object.comments.visible.top_level.by_sticky
      elsif object.respond_to?(:children)
        object.children
      else
        ErrorReporting.report_error_message('Invalid commentable passed to API::V2::Resolvers::Comments::SearchResolver',
                                            extra: { object: object })
        Comment.none
      end
    end

    option :order, type: API::V2::Types::CommentsOrderType, description: 'Define order for the Comments.', default: 'NEWEST'

    def apply_order_with_newest(scope)
      scope.order(created_at: :desc)
    end

    def apply_order_with_votes_count(scope)
      scope.by_credible_votes_count.order(created_at: :desc)
    end
  end
end
