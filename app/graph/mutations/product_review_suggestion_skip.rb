# frozen_string_literal: true

module Graph::Mutations
  class ProductReviewSuggestionSkip < BaseMutation
    argument_record :product, Product

    require_current_user

    def perform(product:)
      Products::SkipReviewSuggestion.find_or_create_by!(
        user: current_user,
        product: product,
      )

      Reviews.clean_suggested_products_cache(user_id: current_user.id)

      nil
    end
  end
end
