# frozen_string_literal: true

module API::V2Internal::Types
  module VotableInterfaceType
    include API::V2Internal::Types::BaseInterface

    graphql_name 'Votable'

    field :id, ID, null: false
    field :votes_count, Int, null: false
    field :has_voted, Boolean, resolver: API::V2Internal::Resolvers::Votes::HasVotedResolver, null: false

    field :voters, API::V2Internal::Types::UserType.connection_type, max_page_size: 20, resolver: API::V2Internal::Resolvers::Votes::VotersResolver, connection: true, null: false
  end
end
