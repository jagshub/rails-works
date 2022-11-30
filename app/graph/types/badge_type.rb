# frozen_string_literal: true

module Graph::Types
  class BadgeType < BaseUnion
    possible_types(
      Graph::Types::Badges::TopPostBadgeType,
      Graph::Types::Badges::GoldenKittyAwardBadgeType,
      Graph::Types::Badges::TopPostTopicBadgeType,
    )
  end
end
