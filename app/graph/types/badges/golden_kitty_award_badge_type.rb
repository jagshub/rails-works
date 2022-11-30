# frozen_string_literal: true

module Graph::Types
  class Badges::GoldenKittyAwardBadgeType < BaseObject
    graphql_name 'GoldenKittyAwardBadge'

    field :id, ID, null: false
    field :position, Int, null: false
    field :category, String, null: false
    field :year, String, null: false
    field :card_image_uuid, resolver: Graph::Resolvers::GoldenKittyBadgeCardResolver
    association :post, Graph::Types::PostType, null: false, preload: :subject
  end
end
