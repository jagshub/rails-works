# frozen_string_literal: true

module Mobile::Graph::Types
  class Badges::GoldenKittyAwardBadgeType < BaseObject
    graphql_name 'GoldenKittyAwardBadge'

    field :id, ID, null: false
    field :position, Int, null: false
    field :category, String, null: false
    field :year, String, null: false
    field :card_image_uuid, String, null: true
    association :post, Mobile::Graph::Types::PostType, null: false, preload: :subject

    def card_image_uuid
      GoldenKitty::Edition.find_by(year: object.year)&.card_image_uuid
    end
  end
end
