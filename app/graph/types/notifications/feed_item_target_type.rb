# frozen_string_literal: true

module Graph::Types
  class Notifications::FeedItemTargetType < BaseUnion
    possible_types(
      Graph::Types::PostType,
      Graph::Types::Discussion::ThreadType,
      Graph::Types::CommentType,
      Graph::Types::ReviewType,
    )
  end
end
