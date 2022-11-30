# frozen_string_literal: true

module Graph::Types
  class ActivityEventSubjectType < BaseUnion
    possible_types(
      PostType,
      ::Graph::Types::Badges::TopPostBadgeType,
      ::Graph::Types::Badges::GoldenKittyAwardBadgeType,
      ::Graph::Types::Products::ReviewSummaryType,
      ::Graph::Types::Anthologies::StoryType,
    )
  end

  class Products::ActivityEventType < BaseObject
    field :id, ID, null: false
    association :subject, ActivityEventSubjectType, null: false
    field :occurred_at, DateTimeType, null: false
    field :votes_count, Integer, null: false
    field :comments_count, Integer, null: false
    field :nominations_count, Integer, null: false
  end
end
