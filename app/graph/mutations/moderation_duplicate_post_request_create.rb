# frozen_string_literal: true

module Graph::Mutations
  class ModerationDuplicatePostRequestCreate < BaseMutation
    argument_record :post, Post, required: true
    argument :url, String, required: true
    argument :reason, String, required: true

    require_current_user

    returns Boolean

    def perform(post:, url:, reason:)
      return true if ::Moderation::DuplicatePost.pending_request?(post, current_user)

      ::Moderation::DuplicatePost.create_request(
        post: post,
        user: current_user,
        reason: reason,
        url: url,
      )

      true
    end
  end
end
