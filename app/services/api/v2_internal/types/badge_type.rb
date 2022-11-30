# frozen_string_literal: true

class API::V2Internal::Types::BadgeType < API::V2Internal::Types::BaseUnion
  graphql_name 'Badge'

  possible_types(
    ::API::V2Internal::Types::Badges::TopPostBadgeType,
    ::API::V2Internal::Types::Badges::GoldenKittyAwardBadgeType,
  )
end
