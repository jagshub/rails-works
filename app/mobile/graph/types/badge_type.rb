# frozen_string_literal: true

class Mobile::Graph::Types::BadgeType < Mobile::Graph::Types::BaseUnion
  graphql_name 'Badge'

  possible_types(
    ::Mobile::Graph::Types::Badges::TopPostBadgeType,
    ::Mobile::Graph::Types::Badges::GoldenKittyAwardBadgeType,
  )
end
