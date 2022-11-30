# frozen_string_literal: true

module Graph::Mutations
  class ModerationReviewUnhide < BaseMutation
    argument_record :review, Review, required: true, authorize: :moderate

    returns Graph::Types::ReviewType

    def perform(review:)
      Moderation.review_unhide(review: review)
      review
    end
  end
end
