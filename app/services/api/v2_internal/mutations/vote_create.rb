# frozen_string_literal: true

module API::V2Internal::Mutations
  class VoteCreate < BaseMutation
    node :votable

    authorize :create do |node|
      Vote.new(subject: node)
    end

    returns API::V2Internal::Types::VotableInterfaceType

    def perform
      ::Voting.create(
        subject: node,
        # NOTE(Dhruv): Internal V2 API is used only by mobile app for now, feel
        # free to change source incase its exposed to more apps in future.
        source: :mobile,
        user: current_user,
        request_info: request_info,
      )

      node
    end
  end
end
