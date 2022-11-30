module Mutations
  class RemoveVote < Mutations::BaseMutation
    null true

    argument :post_id, ID, required: false

    type Types::VoteType

    def resolve(post_id: nil)
      check_authentication!

      vote = Vote.where(post_id: post_id, user_id: context[:current_user].id).first
      unless vote.nil?
        vote.destroy
      else
        raise ActiveRecord::RecordInvalid
      end
    rescue ActiveRecord::RecordInvalid => e
      GraphQL::ExecutionError.new("vote not found")
    end
  end
end
