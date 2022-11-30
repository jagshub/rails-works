# frozen_string_literal: true

module Graph::Mutations
  class ReviewDestroy < BaseMutation
    argument_record :review, ::Review, required: true, authorize: :destroy

    returns Graph::Types::ReviewType

    def perform(review:)
      review.destroy!

      review
    end
  end
end
