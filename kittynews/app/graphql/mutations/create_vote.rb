module Mutations
  class CreateVote < Mutations::BaseMutation
    argument :post_id, ID, required: false

    type Types::VoteType

    def resolve(post_id: nil)
      check_authentication!
      Vote.create!(
        post: Post.find(post_id),
        user: context[:current_user]
      )
    rescue ActiveRecord::RecordInvalid => e
      GraphQL::ExecutionError.new("Invalid input: #{e.record.errors.full_messages.join(', ')}")
    end
  end
end
