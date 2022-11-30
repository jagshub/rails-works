module Mutations
  class AddComment < Mutations::BaseMutation
    null true

    argument :post_id, ID, required: true
    argument :user_id, ID, required: true
    argument :text, String, required: true

    type Types::CommentType

    def resolve(post_id: nil, user_id: nil, text:nil)
      check_authentication!
      Comment.create!(post_id: post_id, user_id: user_id, text: text)
    rescue ActiveRecord::RecordInvalid => e
      GraphQL::ExecutionError.new("cannot create comment" + e.message)
    end
  end
end
