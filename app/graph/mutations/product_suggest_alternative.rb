# frozen_string_literal: true

module Graph::Mutations
  class ProductSuggestAlternative < BaseMutation
    argument_record :product, Product, required: true
    argument_record :alternative_product, Product, required: true
    argument :source, String, required: true

    def perform(product:, alternative_product:, source:)
      ::Stacks.suggest_alternative(
        product: product,
        alternative_product: alternative_product,
        user: current_user,
        source: source,
      )
    end
  end
end
