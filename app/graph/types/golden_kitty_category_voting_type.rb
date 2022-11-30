# frozen_string_literal: true

module Graph::Types
  class GoldenKittyCategoryVotingType < BaseNode
    field :next_category, Graph::Types::GoldenKittyCategoryType, null: true
    field :prev_category, Graph::Types::GoldenKittyCategoryType, null: true
    field :finalists, [Graph::Types::GoldenKittyFinalistType], null: false
    field :people, [Graph::Types::UserType], null: false
    field :kind, Graph::Types::GoldenKittyCategoryKindType, null: false
  end
end
