# frozen_string_literal: true

module Mobile::Graph::Types
  class KarmaBadgeType < BaseObject
    graphql_name 'KarmaBadge'

    field :score, Int, null: false
    field :kind, Mobile::Graph::Types::KarmaBadgeTypesEnum, null: false
  end
end
