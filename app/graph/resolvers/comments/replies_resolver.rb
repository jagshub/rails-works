# frozen_string_literal: true

class Graph::Resolvers::Comments::RepliesResolver < Graph::Resolvers::Base
  argument :all_for_comment_id, ID, required: false

  def resolve(all_for_comment_id: nil)
    return [] if object.replies_count.zero?
    return object.children if all_for_comment_id.nil?

    RepliesResolver.for(all_for_comment_id).load(object)
  end

  class RepliesResolver < GraphQL::Batch::Loader
    def initialize(all_for_comment_id)
      @all_for_comment_id = all_for_comment_id
    end

    def perform(objects)
      comment = Comment.find_by(id: @all_for_comment_id)

      objects.each do |object|
        if comment && (object.id == comment.id || object.id == comment.parent_comment_id)
          fulfill object, WrappedComment.new(object)
        else
          fulfill object, object.children
        end
      end
    end
  end

  WrappedComment = Struct.new(:comment)

  class RepliesConnection < GraphQL::Pagination::ActiveRecordRelationConnection
    # rubocop: disable Lint/UnusedMethodArgument
    def initialize(wraped, arguments, field: nil, max_page_size: nil, parent: nil, context: nil)
      super(
        wraped.comment.children,
        arguments: arguments[:arguments],
        field: arguments[:field],
        max_page_size: wraped.comment.replies_count,
        parent: arguments[:parent],
        context: arguments[:context]
      )
    end
    # rubocop: enable Lint/UnusedMethodArgument

    def total_count
      max_page_size
    end

    def first
      max_page_size
    end
  end
end
