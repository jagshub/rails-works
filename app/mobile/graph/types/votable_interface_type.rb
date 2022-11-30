# frozen_string_literal: true

module Mobile::Graph::Types
  module VotableInterfaceType
    include Mobile::Graph::Types::BaseInterface

    graphql_name 'Votable'

    field :id, ID, null: false
    field :votes_count, Int, null: false
    field :has_voted, resolver: Mobile::Graph::Resolvers::Votes::HasVoted
  end
end
