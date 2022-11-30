# frozen_string_literal: true

module Graph::Resolvers::Moderation
  class ReverseProductAssociationsResolver < Graph::Resolvers::Base
    type [Graph::Types::ProductAssociationType], null: false

    argument :product_id, ID, required: true

    def resolve(product_id:)
      product = Product.find_by(id: product_id)
      return [] if product.nil?

      product.product_reverse_associations.by_date.where(relationship: 'addon')
    end
  end
end
