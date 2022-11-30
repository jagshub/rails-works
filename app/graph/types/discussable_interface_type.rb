# frozen_string_literal: true

module Graph::Types
  module DiscussableInterfaceType
    include Graph::Types::BaseInterface

    field :can_discuss, resolver: Graph::Resolvers::Can.build(:create_discussion)

    field :discussions_count, Integer, null: false

    field :pinned_discussions,
          [Graph::Types::Discussion::ThreadType],
          null: false

    field :top_discussions,
          Graph::Types::Discussion::ThreadType.connection_type,
          null: false,
          max_page_size: 25

    def top_discussions
      object
        .discussions
        .visible
        .where(::Discussion::Thread.arel_table[:trending_at].gt(1.week.ago))
        .order(trending_at: :desc)
    end
  end
end
