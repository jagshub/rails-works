# frozen_string_literal: true

module Graph::Types
  class GoldenKittyFinalistType < BaseObject
    graphql_name 'GoldenKittyFinalist'

    field :id, ID, null: false
    field :post, Graph::Types::PostType, null: false
    field :votes_count, Int, null: false
    field :has_voted, Boolean, null: false, resolver: Graph::Resolvers::GoldenKitty::IsVotedResolver
    field :category_name, String, null: false
    field :voting_ended, Boolean, null: false

    def category_name
      object.golden_kitty_category.name
    end

    def voting_ended
      ::GoldenKitty::Utils.voting_ended?
    end
  end
end
