# frozen_string_literal: true

module API::V2Internal::Types
  class KarmaBadgeType < BaseObject
    graphql_name 'KarmaBadge'

    field :score, Int, null: false
    field :kind, API::V2Internal::Types::KarmaBadgeTypesEnum, null: false
  end
end
