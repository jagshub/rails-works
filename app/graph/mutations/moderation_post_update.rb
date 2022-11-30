# frozen_string_literal: true

module Graph::Mutations
  class ModerationPostUpdate < BaseMutation
    argument_record :post, Post, required: true, authorize: :moderate

    argument :action, String, required: false
    argument :featured_at, String, required: false
    argument :bump_post, Boolean, required: false
    argument :reason, String, required: false
    argument :custom_reason, String, required: false
    argument :share_public, Boolean, required: false
    argument :message, String, required: false

    returns Graph::Types::PostType

    def perform(post:, **inputs)
      Moderation.update_post(by: current_user, post: post, inputs: inputs)
      post
    end
  end
end
