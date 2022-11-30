# frozen_string_literal: true

module Graph::Mutations
  class ModerationPostReview < BaseMutation
    argument_record :post, Post, required: true, authorize: :moderate

    returns Graph::Types::PostType

    def perform(post:)
      Moderation.review_post(by: current_user, post: post)
      post
    end
  end
end
