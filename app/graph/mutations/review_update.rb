# frozen_string_literal: true

module Graph::Mutations
  class ReviewUpdate < BaseMutation
    argument_record :review, ::Review, required: true, authorize: :update
    argument :rating, Int, required: true
    argument :overall_experience, String, required: false
    argument :currently_using, Graph::Types::Reviews::CurrentlyUsingType, required: false
    argument :review_tags, [Graph::Types::Reviews::TagInputType], required: false

    returns Graph::Types::ReviewType

    def perform(inputs)
      HandleRaceCondition.call(transaction: true) do
        form = ::Reviews::Form.new(
          user: current_user,
          review: inputs[:review],
          review_tags: inputs[:review_tags],
          request_info: request_info,
        )

        form.update inputs

        form
      end
    end
  end
end
