# frozen_string_literal: true

module Mobile::Graph::Types
  class Notifications::FeedItemTargetType < BaseUnion
    possible_types(
      Mobile::Graph::Types::PostType,
      Mobile::Graph::Types::Discussion::ThreadType,
      Mobile::Graph::Types::CommentType,
    )
  end
end
