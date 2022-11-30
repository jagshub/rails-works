# frozen_string_literal: true

module Graph::Mutations
  class ReviewCreate < BaseMutation
    argument_record :subject, [Post, Product], required: true
    argument :rating, Int, required: true
    argument :overall_experience, String, required: false
    argument :currently_using, Graph::Types::Reviews::CurrentlyUsingType, required: false
    argument :review_tags, [Graph::Types::Reviews::TagInputType], required: false

    returns Graph::Types::ReviewType

    require_current_user

    def perform(inputs)
      product = if inputs[:subject].is_a?(Product)
                  inputs[:subject]
                else
                  inputs[:subject].new_product
                end

      ApplicationPolicy.authorize! current_user, :create, product.reviews.new(user: current_user)

      HandleRaceCondition.call(transaction: true) do
        form = ::Reviews::Form.new(
          user: current_user,
          product: product,
          review_tags: inputs[:review_tags],
          request_info: request_info,
        )

        form.update inputs
        Reviews.clean_suggested_products_cache(user_id: current_user.id)

        form
      end
    end
  end
end
