# frozen_string_literal: true

module Graph::Types
  class KarmaBadgeType < BaseObject
    graphql_name 'KarmaBadge'

    field :score, Int, null: false
    field :kind, Graph::Types::KarmaBadgeTypesEnum, null: false
  end
end
