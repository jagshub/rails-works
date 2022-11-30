# frozen_string_literal: true

module Graph::Types
  class GoldenKittyCategoryLegacyType < BaseNode
    graphql_name 'GoldenKittyCategoryWrapper'

    class MakerCommunityCategory < BaseNode
      graphql_name 'GoldenKittyMakerCommunityCategory'

      field :emoji, String, null: false
      field :name, String, null: false
      field :tagline, String, null: false
      field :finalists, [Graph::Types::UserType], null: false
    end

    field :categories, [Graph::Types::GoldenKittyCategoryType], null: false
    field :next_categories, [Graph::Types::GoldenKittyCategoryType], null: true
    field :nomination_ended, Boolean, null: false
    field :voting_ended, Boolean, null: false
    field :maker, MakerCommunityCategory, null: false
    field :community, MakerCommunityCategory, null: false
  end
end
