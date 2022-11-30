# frozen_string_literal: true

module Graph::Mutations
  class ModerationProductAssociationUpdate < BaseMutation
    argument_record :product, Product, required: true, authorize: :moderate
    argument_record :associated_product, Product, required: true
    argument :relationship, Graph::Types::ProductAssociationType::RelationshipEnumType, required: true

    def perform(product:, associated_product:, relationship:)
      Moderation.update_associated_product(
        by: current_user,
        product: product,
        associated_product: associated_product,
        relationship: relationship,
      )

      nil
    end
  end
end
