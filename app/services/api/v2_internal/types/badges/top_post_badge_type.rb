# frozen_string_literal: true

module API::V2Internal::Types
  class Badges::TopPostBadgeType < BaseObject
    graphql_name 'TopPostBadge'

    field :id, ID, null: false
    field :position, Int, null: false
    field :period, String, null: false
    field :date, DateTimeType, null: false
  end
end
