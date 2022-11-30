# frozen_string_literal: true

module Graph::Types
  class GoldenKittyHallOfFameType < BaseObject
    graphql_name 'GoldenKittyHallOfFame'

    field :edition, Graph::Types::GoldenKittyEditionType, null: false
    field :years, [Int], null: false
  end
end
