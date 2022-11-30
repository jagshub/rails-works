# frozen_string_literal: true

module Graph::Types
  module VotableInterfaceType
    include Graph::Types::BaseInterface

    graphql_name 'Votable'

    field :id, ID, null: false
    field :votes_count, Int, null: false
    field :has_voted, resolver: Graph::Resolvers::Votes::HasVotedResolver

    field :voters, Graph::Types::UserType.connection_type, max_page_size: 50, resolver: Graph::Resolvers::Votes::VotersResolver, connection: true, null: false
    field :notable_voters, Graph::Types::UserType.connection_type, max_page_size: 20,
                                                                   resolver: Graph::Resolvers::Votes::NotableVotersResolver, connection: true, null: false
  end
end
