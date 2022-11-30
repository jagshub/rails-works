# frozen_string_literal: true

module API::V2Internal::Mutations
  class VoteDestroy < BaseMutation
    node :votable

    authorize :create do |node|
      Vote.new(subject: node)
    end

    returns API::V2Internal::Types::VotableInterfaceType

    def perform
      ::Voting.destroy(subject: node, user: current_user)

      node
    end
  end
end
