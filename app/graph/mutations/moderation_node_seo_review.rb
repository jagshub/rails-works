# frozen_string_literal: true

module Graph::Mutations
  class ModerationNodeSeoReview < BaseMutation
    argument_record :post, Post, authorize: :moderate

    returns Graph::Types::PostType

    def perform(post:)
      Moderation.seo_review by: current_user, reference: post

      post
    end
  end
end
