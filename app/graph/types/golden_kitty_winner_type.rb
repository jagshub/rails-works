# frozen_string_literal: true

module Graph::Types
  class GoldenKittyWinnerType < BaseNode
    class SubjectType < BaseUnion
      graphql_name 'GoldenKittyWinnerSubjectType'

      possible_types(
        Graph::Types::GoldenKittyFinalistType,
        Graph::Types::GoldenKittyPersonType,
      )
    end

    field :subject, SubjectType, null: false
    field :position, Int, null: false

    def subject
      object
    end
  end
end
