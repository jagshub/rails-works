# frozen_string_literal: true

module API::V2::Types::VotableInterfaceType
  include API::V2::Types::BaseInterface
  description 'An object which users can vote for.'

  field :id, ID, 'ID of the object',  null: false
  field :votes_count, Int, 'Number of votes that the object has currently.', null: false
  field :is_voted, Boolean, 'Whether the Viewer has voted for the object or not.', resolver: API::V2::Resolvers::Votes::IsVotedResolver, complexity: 2

  field :votes, API::V2::Types::VoteType.connection_type, null: false, resolver: API::V2::Resolvers::Votes::SearchResolver
end
