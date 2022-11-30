# frozen_string_literal: true

module Mobile::Graph::Types
  class HomefeedItemType < BaseUnion
    possible_types(
      Mobile::Graph::Types::PostType,
      Mobile::Graph::Types::Ads::ChannelType,
      Mobile::Graph::Types::Anthologies::StoryType,
      Mobile::Graph::Types::Discussion::ThreadType,
    )
  end
end
