# frozen_string_literal: true

module Graph::Mutations
  class ModerationProductAssociationCreate < BaseMutation
    argument_record :product, Product, required: true, authorize: :moderate
    argument_record :associated_product, Product, required: true
    argument :relationship, Graph::Types::ProductAssociationType::RelationshipEnumType, required: false

    returns Graph::Types::ProductAssociationType

    def perform(product:, associated_product:, relationship: nil)
      Moderation.add_associated_product(
        by: current_user,
        product: product,
        associated_product: associated_product,
        relationship: relationship,
      )

      product.product_associations.find_by(associated_product_id: associated_product.id)
    end
  end
end
