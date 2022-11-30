# frozen_string_literal: true

module Graph::Types
  class HomefeedItemType < BaseUnion
    possible_types(
      PostType,
      Ads::ChannelType,
      Anthologies::StoryType,
      Discussion::ThreadType,
      CollectionType,
    )
  end
end
