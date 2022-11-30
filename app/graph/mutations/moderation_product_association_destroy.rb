# frozen_string_literal: true

module Graph::Mutations
  class ModerationProductAssociationDestroy < BaseMutation
    argument_record :product, Product, required: true, authorize: :moderate
    argument_record :associated_product, Product, required: true

    def perform(product:, associated_product:)
      Moderation.remove_associated_product(
        by: current_user,
        product: product,
        associated_product: associated_product,
      )

      nil
    end
  end
end
