# frozen_string_literal: true

module Graph::Mutations
  class ModerationPostTrash < BaseMutation
    argument_record :post, Post, required: true, authorize: :moderate

    returns Graph::Types::PostType

    def perform(post:)
      Moderation.trash_post(by: current_user, post: post, reason: '')
      post
    end
  end
end
