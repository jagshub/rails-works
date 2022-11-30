# frozen_string_literal: true

module API::V2Internal::Types
  class Badges::GoldenKittyAwardBadgeType < BaseObject
    graphql_name 'GoldenKittyAwardBadge'

    field :id, ID, null: false
    field :position, Int, null: false
    field :category, String, null: false
    field :year, String, null: false
  end
end
